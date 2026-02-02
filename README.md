# QBrush

QBrush 是一款基于 SwiftUI 开发的现代化智能刷题与学习辅助应用，旨在帮助用户高效管理题库、进行个性化练习并实时追踪学习进度。

![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-green)
![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20Clean-purple)

## ✨ 主要功能

- **多维度题库管理**
  - **全题型支持**：覆盖选择题、填空题、判断题及解答题。
  - **多语言适配**：专为汉语、古文、英语、韩语等学习场景优化。
  - **难度分级**：支持简单、中等、困难（星级展示）三级难度标记。

- **便捷导入**
  - **手动录入**：提供详细的结构化表单，支持选项、答案解析及标签管理。
  - **文本导入**：支持批量文本粘贴导入，快速构建个人题库。

- **学习辅助**
  - **语音朗读 (TTS)**：内置文本转语音功能，辅助语言学习与听力训练。
  - **数据持久化**：基于 CoreData 的本地存储，保障数据安全与离线访问。

## 🛠 技术栈与架构

本项目采用现代化的 iOS 开发架构：

- **开发语言**: Swift 5.5+
- **并发模型**: Swift Concurrency (Async/Await) - *已全面重构替换 Combine/GCD*
- **UI 框架**: SwiftUI
- **架构模式**: MVVM + Clean Architecture
  - **Presentation Layer**: SwiftUI Views + ViewModels (@MainActor)
  - **Domain/Service Layer**: QuestionService (业务逻辑与验证)
  - **Data Layer**: QuestionRepository (Core Data 封装, Actor-isolated)
- **数据存储**: CoreData
- **代码规范**: SwiftLint

## 📂 推荐项目结构

建议将文件组织如下以符合现代化标准：

```
QBrush/
├── App/                   # 应用入口与配置
│   ├── QBrushApp.swift
│   └── Assets.xcassets
├── Features/              # 功能模块
│   ├── QuestionList/      # 题库列表模块
│   │   ├── Views/
│   │   └── ViewModels/
│   └── QuestionImport/    # 导入模块
├── Core/                  # 核心基础库
│   ├── Persistence.swift  # Core Data 栈
│   └── Utilities/
├── Services/              # 业务逻辑服务
│   └── QuestionService.swift
├── Repositories/          # 数据访问层
│   └── QuestionRepository.swift
└── Models/                # 数据模型
    └── Question.swift
```

## 🚀 快速开始

1. **环境要求**
   - macOS 12.0+
   - Xcode 14.0+
   - iOS 15.0+ (如运行在 iOS 设备)

2. **运行步骤**
   ```bash
   # 1. 克隆或下载项目代码
   git clone <repository-url>
   
   # 2. 安装 SwiftLint (推荐)
   brew install swiftlint
   
   # 3. 使用 Xcode 打开项目
   open QBrush.xcodeproj
   
   # 4. 选择目标设备 (Simulator 或真机) 并运行 (Cmd + R)
   ```

## 📝 待办事项 (TODO)

- [x] 现代化重构：迁移至 Async/Await
- [x] 架构分层：引入 Repository 和 Service 层
- [ ] 增加智能刷题算法与推荐逻辑
- [ ] 支持更多格式的文件导入 (CSV/JSON)
- [ ] 集成 iCloud 同步功能

---
Created by bgcode
