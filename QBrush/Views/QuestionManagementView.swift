//
//  QuestionManagementView.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import SwiftUI

struct QuestionManagementView: View {
    @StateObject private var viewModel = QuestionListViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // 搜索栏
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // 筛选器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterChip(title: "全部", isSelected: viewModel.selectedType == nil) {
                            viewModel.selectedType = nil
                        }
                        ForEach(["选择题", "填空题", "判断题", "解答题"], id: \.self) { type in
                            FilterChip(title: type, isSelected: viewModel.selectedType == type) {
                                viewModel.selectedType = type
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                // 列表内容
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if viewModel.questions.isEmpty {
                    VStack {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("暂无题目")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.questions, id: \.id) { question in
                            NavigationLink(destination: QuestionDetailView(question: question)) {
                                QuestionRow(question: question)
                            }
                        }
                        .onDelete(perform: deleteQuestions)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationTitle("题库管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                // 复用导入页面或新建编辑页
                ImportQuestionView() 
            }
            .alert(item: Binding<String?>(
                get: { viewModel.errorMessage },
                set: { viewModel.errorMessage = $0 }
            )) { msg in
                Alert(title: Text("错误"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func deleteQuestions(offsets: IndexSet) {
        offsets.map { viewModel.questions[$0] }.forEach { question in
            viewModel.deleteQuestion(question)
        }
    }
}

// MARK: - Components

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("搜索题目...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
//        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
//                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct QuestionRow: View {
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question.content ?? "无内容")
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                Label(question.type ?? "未知", systemImage: "tag")
                    .font(.caption)
                    .padding(4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(question.createdAt ?? Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct QuestionDetailView: View {
    let question: Question
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.content ?? "")
                    .font(.title2)
                    .bold()
                
                Divider()
                
                if let options = question.options, !options.isEmpty {
                    Text("选项")
                        .font(.headline)
                    Text(options) // 这里可以解析 JSON 显示
                }
                
                Group {
                    Text("正确答案")
                        .font(.headline)
                        .padding(.top)
                    Text(question.correctAnswer ?? "未设置")
                        .foregroundColor(.green)
                    
                    Text("解析")
                        .font(.headline)
                        .padding(.top)
                    Text(question.analysis ?? "暂无解析")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("题目详情")
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
