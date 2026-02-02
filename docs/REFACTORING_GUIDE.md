# 重构迁移指南

本指南旨在协助开发者完成 `QBrush` 项目的现代化架构重构。
我们已经完成了代码层面的大部分重构，包括迁移至 Async/Await、分离数据访问层等。

为了使项目结构与代码架构保持一致，请按照以下步骤在 Xcode 中整理文件。

## 1. 整理文件结构 (在 Xcode 中操作)

请在 Xcode 的 Project Navigator 中创建以下 Group (黄色文件夹)，并将现有文件拖入对应位置：

### App
- `QBrushApp.swift`
- `Assets.xcassets`
- `QBrush.entitlements`

### Core
- `Core/Persistence.swift` (新文件，请手动添加到项目)
- `Data/QBrush.xcdatamodeld` (建议移动到这里)

### Features
- **QuestionList** (新建 Group)
    - `Views/ContentView.swift`
    - `Views/QuestionManagementView.swift`
    - `Views/MainComponents.swift`
    - `Views/QView.swift`
    - `Views/QuestionListViewModel.swift`
- **QuestionImport** (新建 Group)
    - `Views/ImportQuestionView.swift`

### Services
- `Tool/QuestionService.swift` (请重命名 `Tool` Group 为 `Services` 或移动文件)

### Repositories
- `Tool/QuestionRepository.swift` (请移动到 `Repositories` Group)

### Models
- `Models/Question.swift`

## 2. 添加新文件

我已经在文件系统中创建了 `QBrush/Core/Persistence.swift`。
请在 Xcode 中：
1. 右键点击 `QBrush` 组。
2. 选择 "Add Files to 'QBrush'..."。
3. 选择 `QBrush/Core/Persistence.swift` 并添加。

## 3. 验证

完成移动后，请尝试 Build (Cmd+B) 项目。
如果遇到 "File not found" 错误，请检查 Build Phases -> Compile Sources，确保所有 swift 文件都已包含在内。

## 4. 运行测试

请运行 `QBrushTests` (Cmd+U) 以验证 CRUD 功能是否正常。我们已经更新了测试代码以支持 Async/Await。
