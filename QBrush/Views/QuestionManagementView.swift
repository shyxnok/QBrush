//
//  QuestionManagementView.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import SwiftUI

struct QuestionManagementView: View {
    @StateObject private var viewModel = QuestionManagementViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Filter Header
                    QuestionFilterView(
                        selectedType: $viewModel.selectedType,
                        selectedDifficulty: $viewModel.selectedDifficulty,
                        availableTags: viewModel.availableTags,
                        selectedTags: $viewModel.selectedTags,
                        onToggleTag: { tag in viewModel.toggleTag(tag) }
                    )
                        .padding(.vertical, 8)
                        .background(Color.systemBackground)
                    
                    // Main List
                    if viewModel.isLoading && viewModel.questions.isEmpty {
                        SkeletonListView()
                    } else if viewModel.questions.isEmpty {
                        EmptyStateView()
                    } else {
                        QuestionListView(viewModel: viewModel)
                    }
                }
                
                // Floating Action Button
                if !viewModel.isMultiSelectionMode {
                    FloatingActionButton {
                        showingAddSheet = true
                    }
                    .padding()
                    .padding(.bottom, 20) // Adjust for safe area
                }
                
                // Snackbar
                if let message = viewModel.snackbarMessage {
                    SnackbarView(message: message)
                        .padding(.bottom, 80)
                }
            }
            .navigationTitle(Text("question_management_title", bundle: .main))
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Menu {
                            Picker("", selection: $viewModel.sortOption) {
                                Text("sort_updated_desc", bundle: .main).tag(QuestionManagementViewModel.SortOption.updatedDesc)
                                Text("sort_created_desc", bundle: .main).tag(QuestionManagementViewModel.SortOption.createdDesc)
                                Text("sort_type_asc", bundle: .main).tag(QuestionManagementViewModel.SortOption.typeAsc)
                                Text("sort_difficulty_asc", bundle: .main).tag(QuestionManagementViewModel.SortOption.difficultyAsc)
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        Button {
                            withAnimation {
                                viewModel.isMultiSelectionMode.toggle()
                            }
                        } label: {
                            Text(viewModel.isMultiSelectionMode ? "done_action" : "select_action", bundle: .main)
                        }
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Menu {
                            Picker("", selection: $viewModel.sortOption) {
                                Text("sort_updated_desc", bundle: .main).tag(QuestionManagementViewModel.SortOption.updatedDesc)
                                Text("sort_created_desc", bundle: .main).tag(QuestionManagementViewModel.SortOption.createdDesc)
                                Text("sort_type_asc", bundle: .main).tag(QuestionManagementViewModel.SortOption.typeAsc)
                                Text("sort_difficulty_asc", bundle: .main).tag(QuestionManagementViewModel.SortOption.difficultyAsc)
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        Button {
                            withAnimation {
                                viewModel.isMultiSelectionMode.toggle()
                            }
                        } label: {
                            Text(viewModel.isMultiSelectionMode ? "done_action" : "select_action", bundle: .main)
                        }
                    }
                }
                #endif
            }
            .overlay(alignment: .bottom) {
                if viewModel.isMultiSelectionMode {
                    MultiSelectionToolbar(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        #if os(iOS)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("search_placeholder", bundle: .main))
        .navigationViewStyle(.stack)
        #else
        .searchable(text: $viewModel.searchText, prompt: Text("search_placeholder", bundle: .main))
        #endif
        .sheet(isPresented: $showingAddSheet) {
            ImportQuestionView()
        }
    }
}

// MARK: - Subcomponents

struct QuestionFilterView: View {
    @Binding var selectedType: String?
    @Binding var selectedDifficulty: String?
    let availableTags: [String]
    @Binding var selectedTags: Set<String>
    let onToggleTag: (String) -> Void
    private let types = ["选择题", "填空题", "判断题", "解答题"]
    private let difficulties = ["简单", "中等", "困难"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: NSLocalizedString("filter_all", comment: ""),
                    isSelected: selectedType == nil
                ) {
                    withAnimation { selectedType = nil }
                }
                
                ForEach(types, id: \.self) { type in
                    FilterChip(
                        title: NSLocalizedString("filter_" + mapTypeToKey(type), comment: ""),
                        isSelected: selectedType == type
                    ) {
                        withAnimation { selectedType = type }
                    }
                }
            }
            .padding(.horizontal)
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: NSLocalizedString("filter_all", comment: ""),
                    isSelected: selectedDifficulty == nil
                ) {
                    withAnimation { selectedDifficulty = nil }
                }
                ForEach(difficulties, id: \.self) { d in
                    FilterChip(
                        title: NSLocalizedString(difficultyKey(d), comment: ""),
                        isSelected: selectedDifficulty == d
                    ) {
                        withAnimation { selectedDifficulty = d }
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        if !availableTags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableTags, id: \.self) { tag in
                        FilterChip(
                            title: tag,
                            isSelected: selectedTags.contains(tag)
                        ) {
                            withAnimation {
                                onToggleTag(tag)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }
    
    private func mapTypeToKey(_ type: String) -> String {
        switch type {
        case "选择题": return "choice"
        case "填空题": return "fill"
        case "判断题": return "judgment"
        case "解答题": return "answer"
        default: return "all"
        }
    }
    
    private func difficultyKey(_ d: String) -> String {
        switch d {
        case "简单": return "difficulty_easy"
        case "中等": return "difficulty_medium"
        case "困难": return "difficulty_hard"
        default: return "difficulty_medium"
        }
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
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondarySystemBackground)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

struct QuestionListView: View {
    @ObservedObject var viewModel: QuestionManagementViewModel
    
    var body: some View {
        List {
            if viewModel.selectedType == nil {
                ForEach(viewModel.groupedSections) { section in
                    Section(header: SectionHeader(title: section.title, count: section.items.count, lastUpdated: latestDate(in: section.items))) {
                        ForEach(section.items) { question in
                            QuestionRowView(
                                question: question,
                                searchText: viewModel.searchText,
                                isSelected: viewModel.isSelected(question),
                                isMultiSelectionMode: viewModel.isMultiSelectionMode
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .background(Color.secondarySystemGroupedBackground)
                            .cornerRadius(12)
                            .padding(.vertical, 4)
                            .onTapGesture {
                                if viewModel.isMultiSelectionMode {
                                    withAnimation {
                                        viewModel.toggleSelection(for: question)
                                    }
                                } else {
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if !viewModel.isMultiSelectionMode {
                                    Button(role: .destructive) {
                                        viewModel.deleteQuestion(question)
                                    } label: {
                                        Label(NSLocalizedString("delete_action", comment: ""), systemImage: "trash")
                                    }
                                    Button {
                                    } label: {
                                        Label(NSLocalizedString("edit_action", comment: ""), systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                            .contextMenu {
                                Button {
                                } label: {
                                    Label(NSLocalizedString("copy_action", comment: ""), systemImage: "doc.on.doc")
                                }
                                Button {
                                } label: {
                                    Label(NSLocalizedString("move_action", comment: ""), systemImage: "folder")
                                }
                                Button {
                                } label: {
                                    Label(NSLocalizedString("mark_action", comment: ""), systemImage: "bookmark")
                                }
                            }
                        }
                    }
                }
            } else {
                ForEach(viewModel.questions) { question in
                QuestionRowView(
                    question: question,
                    searchText: viewModel.searchText,
                    isSelected: viewModel.isSelected(question),
                    isMultiSelectionMode: viewModel.isMultiSelectionMode
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .background(Color.secondarySystemGroupedBackground)
                .cornerRadius(12)
                .padding(.vertical, 4)
                .onTapGesture {
                    if viewModel.isMultiSelectionMode {
                        withAnimation {
                            viewModel.toggleSelection(for: question)
                        }
                    } else {
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if !viewModel.isMultiSelectionMode {
                        Button(role: .destructive) {
                            viewModel.deleteQuestion(question)
                        } label: {
                            Label(NSLocalizedString("delete_action", comment: ""), systemImage: "trash")
                        }
                        
                        Button {
                        } label: {
                            Label(NSLocalizedString("edit_action", comment: ""), systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
                .contextMenu {
                    Button {
                    } label: {
                        Label(NSLocalizedString("copy_action", comment: ""), systemImage: "doc.on.doc")
                    }
                    
                    Button {
                    } label: {
                        Label(NSLocalizedString("move_action", comment: ""), systemImage: "folder")
                    }
                    
                    Button {
                    } label: {
                        Label(NSLocalizedString("mark_action", comment: ""), systemImage: "bookmark")
                    }
                }
            }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.refresh()
        }
    }
}

private func latestDate(in items: [Question]) -> Date? {
    items.compactMap { $0.updatedAt ?? $0.createdAt }.max()
}

struct SectionHeader: View {
    let title: String
    let count: Int
    let lastUpdated: Date?
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Text("\(count)")
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.accentColor.opacity(0.15))
                .foregroundColor(.accentColor)
                .cornerRadius(6)
            Spacer()
            if let date = lastUpdated {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("empty_list_title", bundle: .main)
                .font(.headline)
            Text("empty_list_message", bundle: .main)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
        }
    }
}

struct MultiSelectionToolbar: View {
    @ObservedObject var viewModel: QuestionManagementViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Button(role: .destructive) {
                    viewModel.batchDelete()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("batch_delete", bundle: .main)
                            .font(.caption)
                    }
                }
                .disabled(viewModel.selectedIds.isEmpty)
                
                Spacer()
                
                Button {
                    // Export
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("batch_export", bundle: .main)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                Button {
                    // Print
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "printer")
                        Text("batch_print", bundle: .main)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Material.bar)
        }
    }
}

struct SnackbarView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: message)
    }
}

#Preview {
    QuestionManagementView()
}
