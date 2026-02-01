# QBrush

QBrush 是一款基于 SwiftUI 开发的现代化智能刷题与学习辅助应用，旨在帮助用户高效管理题库、进行个性化练习并实时追踪学习进度。

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

## 🛠 技术栈

- **开发语言**: Swift 5.5+
- **UI 框架**: SwiftUI
- **数据存储**: CoreData
- **平台支持**: iOS / macOS (Universal App)

## 📂 项目结构

```
QBrush/
├── QBrush/
│   ├── Views/                 # 视图层
│   │   ├── ContentView.swift          # 仪表盘主界面
│   │   ├── ImportQuestionView.swift   # 题目导入
│   │   ├── QuestionManagementView.swift # 题目管理
│   │   ├── MainComponents.swift       # 通用 UI 组件
│   │   └── tts.swift                  # 语音合成工具类
│   ├── QBrush.xcdatamodeld/   # CoreData 数据模型
│   └── QBrushApp.swift        # App 生命周期入口
└── QBrush.xcodeproj           # Xcode 项目文件
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
   
   # 2. 使用 Xcode 打开项目
   open QBrush.xcodeproj
   
   # 3. 选择目标设备 (Simulator 或真机) 并运行 (Cmd + R)
   ```

## 📝 待办事项 (TODO)

- [ ] 对接真实数据源 (CoreData) 到仪表盘
- [ ] 增加智能刷题算法与推荐逻辑
- [ ] 支持更多格式的文件导入 (CSV/JSON)
- [ ] 集成 iCloud 同步功能

---
Created by bgcode
