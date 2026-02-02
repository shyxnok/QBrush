# QBrush CRUD 模块使用文档

本文档详细介绍了 QBrush 项目中题目管理模块的 CRUD（增删改查）设计与实现。模块采用 MVVM 架构，分层清晰，便于维护与扩展。

## 1. 架构设计

模块分为四层：
- **Model (Entity)**: CoreData 实体定义 (`Question`)
- **DAO (Repository)**: 数据访问层，负责底层数据库操作 (`QuestionRepository`)
- **Service**: 业务逻辑层，处理验证与业务规则 (`QuestionService`)
- **ViewModel (Controller)**: 状态管理与 UI 绑定 (`QuestionListViewModel`)

## 2. 实体模型 (Entity)

在 `QBrush.xcdatamodeld` 中定义了 `Question` 实体：

| 属性名 | 类型 | 说明 |
| --- | --- | --- |
| id | UUID | 唯一标识符 |
| content | String | 题目内容 |
| type | String | 题目类型 (选择题/填空题等) |
| options | String | 选项 (JSON 格式) |
| correctAnswer | String | 正确答案 |
| analysis | String | 解析 |
| difficulty | String | 难度 |
| tags | String | 标签 |
| createdAt | Date | 创建时间 |

## 3. 核心组件与 API

### 3.1 数据访问层 (DAO)

文件位置: `QBrush/Core/QuestionRepository.swift`

提供了基础的数据库操作方法：

```swift
// 创建题目
func create(content: String, type: String, ...) throws -> Question

// 获取列表 (支持分页、筛选、排序)
func getAll(page: Int, pageSize: Int, type: String?, keyword: String?) throws -> [Question]

// 更新题目
func update(question: Question, content: String?, ...) throws -> Question

// 删除题目
func delete(question: Question) throws
```

### 3.2 业务逻辑层 (Service)

文件位置: `QBrush/Core/QuestionService.swift`

封装了业务规则与异常处理：

```swift
// 添加题目 (包含非空校验)
func addQuestion(content: String, type: String, ...) throws -> Question

// 获取题目列表 (返回 Result 类型)
func getQuestionList(...) -> Result<[Question], QuestionError>
```

### 3.3 控制器层 (ViewModel)

文件位置: `QBrush/ViewModels/QuestionListViewModel.swift`

用于 SwiftUI 视图绑定：

```swift
@Published var questions: [Question] // 数据源
@Published var isLoading: Bool       // 加载状态
@Published var errorMessage: String? // 错误信息

// 意图 (Intents)
func loadQuestions()   // 加载数据
func deleteQuestion(_ question: Question) // 删除数据
func refresh()         // 刷新列表
```

## 4. 使用示例

### 4.1 在 View 中集成

```swift
struct MyView: View {
    @StateObject private var viewModel = QuestionListViewModel()
    
    var body: some View {
        List(viewModel.questions) { question in
            Text(question.content ?? "")
        }
        .onAppear {
            viewModel.loadQuestions()
        }
    }
}
```

### 4.2 添加新题目

```swift
let service = QuestionService()
do {
    try service.addQuestion(
        content: "Swift 是面向对象的语言吗？",
        type: "判断题",
        correctAnswer: "是"
    )
} catch {
    print("添加失败: \(error.localizedDescription)")
}
```

## 5. 异常处理与性能优化

- **异常处理**: 使用 `QuestionError` 枚举统一错误类型，ViewModel 中捕获错误并显示 Alert。
- **分页查询**: Repository 中通过 `fetchLimit` 和 `fetchOffset` 实现分页，避免一次性加载过多数据。
- **搜索优化**: 使用 Combine 的 `.debounce` 操作符，防止搜索框输入时频繁触发数据库查询。
- **事务管理**: `PersistenceController` 的 Context 自动管理事务，`save()` 方法确保原子性。

## 6. 常见问题

- **Q: 数据没有立即刷新？**
  A: 确保 ViewModel 中调用了 `loadQuestions()`，且 View 监听了 `@StateObject`。
- **Q: 编译报错 "Use of undeclared type 'Question'"？**
  A: 确保 CoreData 模型文件已编译，且 Xcode 自动生成了 `Question` 类。如果未生成，请尝试 Clean Build Folder。
