//
//  tts.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//
import SwiftUI

// 题目数据模型（可后续对接CoreData/本地存储）
struct Question: Identifiable {
    let id = UUID()
    var content: String // 题目内容
    var category: String // 分类（如“数学”“英语”）
    var difficulty: Difficulty // 难度
    var isAnswered: Bool = false // 是否答过
    var isCorrect: Bool = false // 是否答对
    
    // 难度枚举
    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "简单"
        case medium = "中等"
        case hard = "困难"
        
        var id: Self { self }
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .orange
            case .hard: return .red
            }
        }
    }
}

// 题库管理页面
struct sQuestionManagementView: View {
    // 模拟题目数据
    @State private var questions: [Question] = [
        Question(content: "2+2等于多少？", category: "数学", difficulty: .easy, isAnswered: true, isCorrect: true),
        Question(content: "苹果的英文是什么？", category: "英语", difficulty: .easy, isAnswered: true, isCorrect: false),
        Question(content: "简述SwiftUI的核心特性", category: "编程", difficulty: .hard, isAnswered: false)
    ]
    
    // 筛选条件
    @State private var selectedCategory: String? = nil
    @State private var selectedDifficulty: Question.Difficulty? = nil
    
    // 弹窗状态
    @State private var showAddQuestionSheet = false
    @State private var editQuestion: Question? = nil
    
    // 所有分类（从题目中提取）
    private var allCategories: [String] {
        let categories = questions.map { $0.category }
        return Array(Set(categories)).sorted()
    }
    
    // 筛选后的题目列表
    private var filteredQuestions: [Question] {
        questions.filter { question in
            // 分类筛选
            if let category = selectedCategory, question.category != category {
                return false
            }
            // 难度筛选
            if let difficulty = selectedDifficulty, question.difficulty != difficulty {
                return false
            }
            return true
        }
    }
    
    var body: some View {
        // 适配iOS/macOS导航
        if #available(iOS 16.0, macOS 13.0, *) {
            NavigationStack {
                mainContent
                    .navigationTitle("题库管理")
                    .toolbar { toolbarItems }
            }
        } else {
            NavigationView {
                mainContent
                    .navigationTitle("题库管理")
                    .toolbar { toolbarItems }
            }
        }
    }
    
    // 工具栏按钮（添加题目）
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: { showAddQuestionSheet = true }) {
                Label("添加题目", systemImage: "plus")
            }
        }
    }
    
    // 主内容布局
    private var mainContent: some View {
        VStack(spacing: 0) {
            // 筛选栏
            filterSection
                .padding(12)
                .background(Color.groupedBackground)
            
            // 题目列表
            List {
                ForEach(filteredQuestions) { question in
                    QuestionRow(question: question)
                        .swipeActions(edge: .trailing) {
                            // 编辑按钮
                            Button {
                                editQuestion = question
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            .tint(.blue)
                            
                            // 删除按钮
                            Button(role: .destructive) {
                                deleteQuestion(question)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .overlay {
                // 空数据提示
                if filteredQuestions.isEmpty {
                    ContentUnavailableView("暂无题目", systemImage: "books.vertical", description: Text("点击右上角“+”添加题目"))
                }
            }
        }
        // 添加/编辑题目弹窗
        .sheet(item: $editQuestion) { question in
            AddEditQuestionView(question: question) { updatedQuestion in
                if let index = questions.firstIndex(where: { $0.id == updatedQuestion.id }) {
                    questions[index] = updatedQuestion
                }
            }
        }
        .sheet(isPresented: $showAddQuestionSheet) {
            AddEditQuestionView { newQuestion in
                questions.append(newQuestion)
            }
        }
    }
    
    // 筛选栏
    private var filterSection: some View {
        HStack(spacing: 16) {
            // 分类筛选
            Menu {
                Button("全部分类") { selectedCategory = nil }
                Divider()
                ForEach(allCategories, id: \.self) { category in
                    Button(category) { selectedCategory = category }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedCategory ?? "分类")
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.primary)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemGray5, lineWidth: 1))
            }
            
            // 难度筛选
            Menu {
                Button("全部难度") { selectedDifficulty = nil }
                Divider()
                ForEach(Question.Difficulty.allCases) { difficulty in
                    Button {
                        selectedDifficulty = difficulty
                    } label: {
                        HStack {
                            Text(difficulty.rawValue)
                            Circle()
                                .fill(difficulty.color)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedDifficulty?.rawValue ?? "难度")
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.primary)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemGray5, lineWidth: 1))
            }
            
            Spacer()
            
            // 重置筛选
            Button {
                selectedCategory = nil
                selectedDifficulty = nil
            } label: {
                Text("重置")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
    
    // 删除题目方法
    private func deleteQuestion(_ question: Question) {
        questions.removeAll { $0.id == question.id }
    }
}

// 题目列表行组件
struct QuestionRow: View {
    let question: Question
    
    var body: some View {
        HStack(spacing: 12) {
            // 难度标识
            Circle()
                .fill(question.difficulty.color)
                .frame(width: 12, height: 12)
            
            // 题目内容和分类
            VStack(alignment: .leading, spacing: 4) {
                Text(question.content)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(question.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if question.isAnswered {
                        Image(systemName: question.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(question.isCorrect ? .green : .red)
                    }
                }
            }
            
            Spacer()
            
            // 右侧箭头（macOS适配）
            #if os(iOS)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            #endif
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemGray5, lineWidth: 0.5))
        .listRowBackground(Color.groupedBackground)
        .listRowSeparator(.hidden)
    }
}

// 添加/编辑题目弹窗
struct AddEditQuestionView: View {
    // 编辑模式：传入已有题目；添加模式：nil
    @State private var content: String
    @State private var category: String
    @State private var difficulty: Question.Difficulty
    
    // 回调：返回新增/编辑后的题目
    let onSave: (Question) -> Void
    // 关闭弹窗
    @Environment(\.dismiss) private var dismiss
    
    // 初始化：添加模式
    init(onSave: @escaping (Question) -> Void) {
        self._content = State(initialValue: "")
        self._category = State(initialValue: "")
        self._difficulty = State(initialValue: .easy)
        self.onSave = onSave
    }
    
    // 初始化：编辑模式
    init(question: Question, onSave: @escaping (Question) -> Void) {
        self._content = State(initialValue: question.content)
        self._category = State(initialValue: question.category)
        self._difficulty = State(initialValue: question.difficulty)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 题目内容
                Section("题目内容") {
                    TextField("请输入题目", text: $content, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                // 分类
                Section("分类") {
                    TextField("请输入分类（如数学/英语）", text: $category)
                }
                
                // 难度
                Section("难度") {
                    Picker("难度", selection: $difficulty) {
                        ForEach(Question.Difficulty.allCases) { diff in
                            HStack {
                                Text(diff.rawValue)
                                Circle()
                                    .fill(diff.color)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(content.isEmpty ? "添加题目" : "编辑题目")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 取消按钮
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                // 保存按钮（内容为空时禁用）
                ToolbarItem(placement: .primaryAction) {
                    Button("保存") {
                        let question = Question(
                            content: content,
                            category: category,
                            difficulty: difficulty
                        )
                        onSave(question)
                        dismiss()
                    }
                    .disabled(content.isEmpty || category.isEmpty)
                }
            }
        }
        .frame(minWidth: 300, maxWidth: 500, minHeight: 300) // macOS适配弹窗大小
    }
}



// 预览
#Preview {
   sQuestionManagementView()
}

#Preview("题目行") {
    QuestionRow(question: Question(content: "测试题目", category: "测试分类", difficulty: .medium))
        .padding()
        .background(Color.groupedBackground)
}

#Preview("添加题目弹窗") {
    AddEditQuestionView { _ in }
}
