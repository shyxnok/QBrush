# QBrush Core Data 集成与 CRUD 模块使用指南

本文档详细说明了如何将 Core Data 持久化方案及 MVVM 架构完整集成到 QBrush 项目中。本指南涵盖项目结构分析、集成步骤、核心代码示例、配置说明、最佳实践、测试验证及性能优化建议。

## 1. 项目结构分析与集成方案

### 1.1 现状分析
QBrush 是一个基于 SwiftUI 的 iOS/macOS 跨平台应用。
- **UI 框架**: SwiftUI
- **数据层**: 原生 Core Data
- **架构模式**: 推荐使用 MVVM (Model-View-ViewModel) 以分离视图与业务逻辑。

### 1.2 集成方案
我们采用 **Repository Pattern (仓储模式)** 封装 Core Data 操作，结合 **Service Layer (服务层)** 处理业务逻辑，最后通过 **ViewModel** 暴露数据给 SwiftUI 视图。

**分层架构图**:
```
[View (SwiftUI)] <-> [ViewModel (ObservableObject)] <-> [Service] <-> [Repository (DAO)] <-> [Core Data (SQLite)]
```

## 2. 逐步集成演示

### 步骤 1: 配置数据模型 (Model)
在 `QBrush.xcdatamodeld` 中定义实体 `Question`：
- 添加属性：`id` (UUID), `content` (String), `type` (String) 等。
- 确保 Codegen 设置为 "Class Definition" 以自动生成 Swift 类。

### 步骤 2: 建立数据访问层 (Repository)
创建 `Core/QuestionRepository.swift`，负责直接与 `NSManagedObjectContext` 交互。
- 封装 `create`, `delete`, `fetch` 等底层 API。
- 屏蔽 Core Data 的复杂查询语法 (NSPredicate)。

### 步骤 3: 建立业务服务层 (Service)
创建 `Core/QuestionService.swift`。
- 处理数据校验（如：题目内容不能为空）。
- 转换错误类型，将 Core Data 错误转换为业务友好的 `QuestionError`。

### 步骤 4: 建立视图模型 (ViewModel)
创建 `ViewModels/QuestionListViewModel.swift`。
- 使用 `@Published` 发布数据变化。
- 处理分页加载、搜索防抖、筛选逻辑。

### 步骤 5: UI 绑定
在 `QuestionManagementView.swift` 中使用 `@StateObject` 注入 ViewModel。

## 3. 核心代码示例

### 3.1 仓储层 (Repository)
```swift
// Core/QuestionRepository.swift
func getAll(page: Int, keyword: String?) throws -> [Question] {
    let request: NSFetchRequest<Question> = Question.fetchRequest()
    request.fetchLimit = 20
    request.fetchOffset = (page - 1) * 20
    
    if let keyword = keyword, !keyword.isEmpty {
        request.predicate = NSPredicate(format: "content CONTAINS[cd] %@", keyword)
    }
    return try context.fetch(request)
}
```

### 3.2 视图模型 (ViewModel)
```swift
// ViewModels/QuestionListViewModel.swift
func loadQuestions() {
    isLoading = true
    // 调用 Service 获取数据
    let result = service.getQuestionList(page: currentPage, keyword: searchText)
    switch result {
    case .success(let data):
        self.questions = data
    case .failure(let error):
        self.errorMessage = error.localizedDescription
    }
    isLoading = false
}
```

## 4. 常见配置参数

| 参数文件 | 参数名 | 作用 | 默认值 |
| --- | --- | --- | --- |
| `Persistence.swift` | `inMemory` | 是否使用内存数据库（用于预览/测试） | `false` |
| `QuestionRepository` | `pageSize` | 单页加载数据条数 | 20 |
| `QuestionListViewModel` | `debounce` | 搜索框防抖时间（毫秒） | 500ms |

## 5. 兼容性与最佳实践

### 5.1 兼容性注意
- **SwiftUI 版本**: 使用了 `NavigationStack` (iOS 16+)，在旧版本需回退到 `NavigationView`。
- **Core Data 并发**: 所有的 UI 数据读取必须在 **Main Queue Context** (`viewContext`) 进行。后台写入需使用 `performBackgroundTask`。

### 5.2 最佳实践
- **依赖注入**: ViewModel 依赖接口（Protocol）而非具体类，便于单元测试 mock。
- **单向数据流**: View 只负责渲染，所有状态修改通过 ViewModel 的 Intent 方法触发。

## 6. 测试验证

已集成集成测试用例 `QBrushTests/QuestionCRUDTests.swift`。

**运行测试命令**:
```bash
xcodebuild test -project QBrush.xcodeproj -scheme QBrush -destination 'platform=iOS Simulator,name=iPhone 14'
```

**测试覆盖**:
- [x] 创建题目并验证属性
- [x] 按关键词搜索查询
- [x] 更新题目内容
- [x] 删除题目并验证消失

## 7. 性能优化与错误处理

### 7.1 性能优化
1.  **分页加载 (Pagination)**: 避免一次性加载数千条数据卡死 UI。
2.  **搜索防抖 (Debounce)**: 避免每输入一个字符就查询数据库。
3.  **批量删除**: 使用 `NSBatchDeleteRequest` 处理大量数据删除，无需加载到内存。

### 7.2 错误处理
- **Repository 层**: 抛出原生 `Error`。
- **Service 层**: 捕获错误并封装为 `QuestionError` (如 `.emptyContent`, `.databaseError`)。
- **UI 层**: 监听 ViewModel 的 `errorMessage`，通过 `.alert` 弹窗提示用户。

```swift
// 错误处理示例
.alert(item: $viewModel.errorMessage) { error in
    Alert(title: Text("操作失败"), message: Text(error), dismissButton: .default(Text("OK")))
}
```
