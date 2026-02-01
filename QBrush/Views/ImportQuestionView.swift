//
//  ImportQuestionView.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import SwiftUI

// 题目类型枚举
enum QuestionType: String, CaseIterable, Identifiable {
    case singleChoice = "选择题"
    case fillBlank = "填空题"
    case judgment = "判断题"
    case answer = "解答题"
    
    var id: Self { self }
}

// 语言类型枚举
enum QuestionLanguage: String, CaseIterable, Identifiable {
    case chinese = "汉语"
    case ancientChinese = "古文"
    case english = "英语"
    case korean = "韩语"
    
    var id: Self { self }
}

// 难度枚举（带星级展示）
enum QuestionDifficulty: String, CaseIterable, Identifiable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"
    
    var id: Self { self }
    var starIcon: String {
        switch self {
        case .easy: return "star"
        case .medium: return "star.fill"
        case .hard: return "star.fill.star.fill"
        }
    }
    var starCount: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

// 导入题目主界面
struct ImportQuestionView: View {
    // 标签页切换状态
    @State private var selectedTab: Int = 0 // 0:手动输入 1:文本导入
    
    // 手动输入表单数据
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var questionType: QuestionType = .singleChoice
    @State private var language: QuestionLanguage = .chinese
    @State private var difficulty: QuestionDifficulty = .medium
    @State private var optionA: String = ""
    @State private var optionB: String = ""
    @State private var optionC: String = ""
    @State private var optionD: String = ""
    @State private var correctAnswer: String = ""
    @State private var answerAnalysis: String = ""
    @State private var tags: String = ""
    
    // 文本导入内容
    @State private var textImportContent: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 顶部标签页
                    tabView
                    
                    // 表单内容（根据标签页切换）
                    if selectedTab == 0 {
                        manualInputForm
                    } else {
                        textImportForm
                    }
                    
                    // 导入说明区域
                    importInstructionSection
                }
                .padding(16)
            }
            .navigationTitle("导入题目")
//            .navigationBarTitleDisplayMode(.inline)
            .background(Color.groupedBackground)
        }
    }
    
    // 顶部标签页
    private var tabView: some View {
        HStack {
            // 手动输入标签
            Button {
                selectedTab = 0
            } label: {
                VStack {
                    HStack {
                        Image(systemName: "text.cursor")
                        Text("手动输入")
                    }
                    .font(.subheadline)
                    
                    // 选中下划线
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selectedTab == 0 ? .blue : .clear)
                }
                .foregroundColor(selectedTab == 0 ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
            
            // 文本导入标签
            Button {
                selectedTab = 1
            } label: {
                VStack {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("文本导入")
                    }
                    .font(.subheadline)
                    
                    // 选中下划线
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selectedTab == 1 ? .blue : .clear)
                }
                .foregroundColor(selectedTab == 1 ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 8)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemGray5, lineWidth: 1))
    }
    
    // 手动输入表单
    private var manualInputForm: some View {
        VStack(spacing: 16) {
            Text("手动添加题目")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 题目标题
            FormField(
                title: "题目标题",
                placeholder: "输入题目标题",
                text: $title,
                isRequired: true
            )
            
            // 题目内容
            FormField(
                title: "题目内容",
                placeholder: "输入题目内容",
                text: $content,
                isRequired: true,
                isMultiline: true,
                lineLimit: 3...8
            )
            
            // 题目类型+语言+难度 行
            HStack(spacing: 12) {
                // 题目类型
                DropdownField(
                    title: "题目类型",
                    selectedValue: $questionType,
                    options: QuestionType.allCases,
                    width: .infinity
                )
                
                // 语言
                DropdownField(
                    title: "语言",
                    selectedValue: $language,
                    options: QuestionLanguage.allCases,
                    width: .infinity
                )
                
                // 难度
                DropdownField(
                    title: "难度",
                    selectedValue: $difficulty,
                    options: QuestionDifficulty.allCases,
                    width: .infinity,
//                    suffixView: {
//                        HStack(spacing: 1) {
//                            ForEach(0..<3) { index in
//                                Image(systemName: index < difficulty.starCount ? "star.fill" : "star")
//                                    .font(.caption)
//                                    .foregroundColor(.yellow)
//                            }
//                        }
//                    }
                )
            }
            
            // 选项区域
            if questionType == .singleChoice {
                VStack(spacing: 12) {
                    Text("选项")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        FormField(
                            title: "选项A",
                            placeholder: "选项A",
                            text: $optionA,
                            width: .infinity
                        )
                        FormField(
                            title: "选项B",
                            placeholder: "选项B",
                            text: $optionB,
                            width: .infinity
                        )
                    }
                    
                    HStack(spacing: 12) {
                        FormField(
                            title: "选项C",
                            placeholder: "选项C",
                            text: $optionC,
                            width: .infinity
                        )
                        FormField(
                            title: "选项D",
                            placeholder: "选项D",
                            text: $optionD,
                            width: .infinity
                        )
                    }
                }
            }
            
            // 正确答案
            FormField(
                title: "正确答案",
                placeholder: "输入正确答案",
                text: $correctAnswer,
                isRequired: true
            )
            
            // 答案解析
            FormField(
                title: "答案解析",
                placeholder: "输入答案解析",
                text: $answerAnalysis,
                isMultiline: true,
                lineLimit: 2...5
            )
            
            // 标签
            FormField(
                title: "标签 (用逗号分隔)",
                placeholder: "例如: 数学,代数,方程",
                text: $tags
            )
            
            // 添加题目按钮
            Button {
                addManualQuestion()
            } label: {
                Text("添加题目")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canAddQuestion ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!canAddQuestion)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.systemGray5, lineWidth: 1))
    }
    
    // 文本导入表单
    private var textImportForm: some View {
        VStack(spacing: 16) {
            Text("文本批量导入")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 文本输入区域
            TextEditor(text: $textImportContent)
                .placeholder(when: textImportContent.isEmpty) {
                    Text("请粘贴符合格式的题目文本（每行一道题，格式：标题|内容|类型|答案）")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .frame(minHeight: 200)
                .padding(8)
                .background(Color.groupedBackground)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemGray5, lineWidth: 1))
            
            // 导入按钮
            Button {
                importTextQuestions()
            } label: {
                Text("批量导入")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(textImportContent.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(textImportContent.isEmpty)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.systemGray5, lineWidth: 1))
    }
    
    // 导入说明区域
    private var importInstructionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("导入说明")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("• 手动输入：适合添加单个题目，可以详细设置各项参数")
                Text("• 文本导入：适合批量导入，使用特定格式快速添加多道题目")
                Text("• 支持的语言：汉语、古文、英语、韩语等")
                Text("• 题目类型：选择题、填空题、判断题、解答题")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.systemGray5, lineWidth: 1))
    }
    
    // MARK: - 辅助方法
    // 判断是否可以添加手动题目（必填项非空）
    private var canAddQuestion: Bool {
        !title.isEmpty && !content.isEmpty && !correctAnswer.isEmpty
    }
    
    // 添加手动输入的题目
    private func addManualQuestion() {
        // 这里添加题目到题库的逻辑（可对接之前的Question模型）
        print("添加题目：\(title) - \(content)")
        // 清空表单
        title = ""
        content = ""
        optionA = ""
        optionB = ""
        optionC = ""
        optionD = ""
        correctAnswer = ""
        answerAnalysis = ""
        tags = ""
        
        // 提示用户添加成功（可替换为Toast/Alert）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("题目添加成功！")
        }
    }
    
    // 导入文本题目
    private func importTextQuestions() {
        // 解析文本内容并批量添加题目
        let lines = textImportContent.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        for line in lines {
            print("导入题目行：\(line)")
            // 解析逻辑示例：按|分割
            let components = line.components(separatedBy: "|")
            if components.count >= 4 {
                let title = components[0]
                let content = components[1]
                let type = components[2]
                let answer = components[3]
                print("解析题目：\(title) - \(content) - \(type) - \(answer)")
            }
        }
        
        // 清空文本框
        textImportContent = ""
        print("批量导入完成，共\(lines.count)道题目")
    }
}

// MARK: - 通用表单组件
// 文本输入字段组件
struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    let isMultiline: Bool
    let lineLimit: ClosedRange<Int>?
    let width: CGFloat?
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isRequired: Bool = false,
        isMultiline: Bool = false,
        lineLimit: ClosedRange<Int>? = nil,
        width: CGFloat? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isRequired = isRequired
        self.isMultiline = isMultiline
        self.lineLimit = lineLimit
        self.width = width
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
            
            if isMultiline {
                TextEditor(text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
//                    .lineLimit(lineLimit)
                    .frame(minHeight: 80)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            }
//            .padding(8)
//            .background(Color.groupedBackground)
//            .cornerRadius(8)
//            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemGray5, lineWidth: 1))
        }
        .frame(width: width)
    }
}

// 下拉选择字段组件
struct DropdownField<T: Identifiable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    @Binding var selectedValue: T
    let options: [T]
    let width: CGFloat?
    var suffixView: (() -> AnyView)?
    
    init(
        title: String,
        selectedValue: Binding<T>,
        options: [T],
        width: CGFloat? = nil,
        suffixView: (() -> AnyView)? = nil
    ) {
        self.title = title
        self._selectedValue = selectedValue
        self.options = options
        self.width = width
        self.suffixView = suffixView
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
            
            Menu {
                ForEach(options) { option in
                    Button(option.rawValue) {
                        selectedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selectedValue.rawValue)
                        .font(.subheadline)
                    if let suffixView = suffixView {
                        suffixView()
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.primary)
                .padding(8)
                .background(Color.groupedBackground)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemGray5, lineWidth: 1))
            }
        }
        .frame(width: width)
    }
}

// MARK: - 扩展：TextField/TextEditor占位符
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}



// MARK: - 预览
#Preview {
    ImportQuestionView()
}

//#Preview("手动输入表单") {
//    ImportQuestionView()
//        .previewLayout(.sizeThatFits)
//        .padding()
//}
//
//#Preview("文本导入表单") {
//    ImportQuestionView()
//        .previewLayout(.sizeThatFits)
//        .padding()
//}
