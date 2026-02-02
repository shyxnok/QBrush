//
//  QuestionManagementViewModel.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Error Handling

enum QuestionManagementError: Error, LocalizedError, Identifiable {
    case databaseError(String, UUID)
    case networkError(String, UUID)
    case unknown(UUID)
    
    var id: UUID {
        switch self {
        case .databaseError(_, let id),
             .networkError(_, let id),
             .unknown(let id):
            return id
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .databaseError(let msg, _): return "Database Error: \(msg)"
        case .networkError(let msg, _): return "Network Error: \(msg)"
        case .unknown: return "Unknown Error"
        }
    }
}

// MARK: - ViewModel

@MainActor
class QuestionManagementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var error: QuestionManagementError?
    @Published var searchText: String = ""
    @Published var selectedType: String? = nil
    @Published var selectedDifficulty: String? = nil
    @Published var sortOption: SortOption = .updatedDesc
    @Published var selectedTags: Set<String> = []
    
    // Multi-selection state
    @Published var isMultiSelectionMode: Bool = false
    @Published var selectedIds: Set<UUID> = []
    @Published var snackbarMessage: String?
    
    // MARK: - Private Properties
    
    private let service: QuestionService
    private var cancellables = Set<AnyCancellable>()
    private var allQuestions: [Question] = [] // Cache for local search filtering
    private var lastModifiedMap: [UUID: Date] = [:] // For incremental updates check
    
    struct SectionData: Identifiable {
        let id = UUID()
        let title: String
        let items: [Question]
    }
    
    enum SortOption: String, CaseIterable {
        case updatedDesc
        case createdDesc
        case typeAsc
        case difficultyAsc
    }
    
    // MARK: - Initialization
    
    init(service: QuestionService = QuestionService()) {
        self.service = service
        setupBindings()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        Publishers.CombineLatest($searchText, $selectedType)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates { prev, curr in
                prev.0 == curr.0 && prev.1 == curr.1
            }
            .sink { [weak self] (text, type) in
                guard let self = self else { return }
                self.filterQuestions(text: text, type: type)
            }
            .store(in: &cancellables)
        $isMultiSelectionMode
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.selectedIds.removeAll()
            }
            .store(in: &cancellables)
        $selectedDifficulty
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.filterQuestions(text: self.searchText, type: self.selectedType)
            }
            .store(in: &cancellables)
        $sortOption
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.filterQuestions(text: self.searchText, type: self.selectedType)
            }
            .store(in: &cancellables)
        $selectedTags
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.filterQuestions(text: self.searchText, type: self.selectedType)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        
        // Wrap async/await service in Future for Combine compatibility as requested
        Future<[Question], Error> { promise in
            Task {
                do {
                    // Simulate network delay for Skeleton demo
                    try await Task.sleep(nanoseconds: 500_000_000)
                    let result = try await self.service.getQuestionList(page: 1, type: nil, keyword: nil)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: RunLoop.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            if case .failure(let err) = completion {
                self.error = .networkError(err.localizedDescription, UUID())
            }
        } receiveValue: { [weak self] loadedQuestions in
            guard let self = self else { return }
            self.handleLoadedQuestions(loadedQuestions)
        }
        .store(in: &cancellables)
    }
    
    private func handleLoadedQuestions(_ newQuestions: [Question]) {
        // Simple incremental check using lastModified
        // In a real app with NSFetchedResultsController, this is handled automatically.
        // Here we simulate it by checking changes.
        
        var hasChanges = false
        if self.allQuestions.count != newQuestions.count {
            hasChanges = true
        } else {
            for q in newQuestions {
                guard let id = q.id else { continue }
                if let oldDate = self.lastModifiedMap[id], let newDate = q.updatedAt, newDate > oldDate {
                    hasChanges = true
                    break
                }
                if self.lastModifiedMap[id] == nil {
                    hasChanges = true
                    break
                }
            }
        }
        
        if hasChanges || self.questions.isEmpty {
            self.allQuestions = newQuestions
            // Update timestamp map
            for q in newQuestions {
                if let id = q.id {
                    self.lastModifiedMap[id] = q.updatedAt
                }
            }
            // Re-apply filters
            self.filterQuestions(text: self.searchText, type: self.selectedType)
        }
    }
    
    // MARK: - Filtering
    
    private func filterQuestions(text: String, type: String?) {
        var result = allQuestions
        if let type = type, !type.isEmpty {
            result = result.filter { $0.type == type }
        }
        if let difficulty = selectedDifficulty, !difficulty.isEmpty {
            result = result.filter { $0.difficulty == difficulty }
        }
        if !text.isEmpty {
            result = result.filter { q in
                guard let content = q.content else { return false }
                return content.localizedCaseInsensitiveContains(text)
            }
        }
        if !selectedTags.isEmpty {
            result = result.filter { q in
                guard let tags = q.tags else { return false }
                let set = Set(tags.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) })
                return !set.intersection(selectedTags).isEmpty
            }
        }
        switch sortOption {
        case .updatedDesc:
            result.sort(by: { (a: Question, b: Question) -> Bool in
                let ad = a.updatedAt ?? a.createdAt ?? Date.distantPast
                let bd = b.updatedAt ?? b.createdAt ?? Date.distantPast
                return ad > bd
            })
        case .createdDesc:
            result.sort(by: { (a: Question, b: Question) -> Bool in
                let ad = a.createdAt ?? Date.distantPast
                let bd = b.createdAt ?? Date.distantPast
                return ad > bd
            })
        case .typeAsc:
            result.sort(by: { (a: Question, b: Question) -> Bool in
                (a.type ?? "") < (b.type ?? "")
            })
        case .difficultyAsc:
            let order = ["简单", "中等", "困难"]
            func difficultyIndex(_ d: String?) -> Int {
                guard let d = d, let i = order.firstIndex(of: d) else { return order.count }
                return i
            }
            result.sort(by: { (a: Question, b: Question) -> Bool in
                difficultyIndex(a.difficulty) < difficultyIndex(b.difficulty)
            })
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            self.questions = result
        }
    }
    
    var groupedSections: [SectionData] {
        if let type = selectedType, !type.isEmpty {
            return [SectionData(title: type, items: questions)]
        }
        let groups = Dictionary(grouping: questions, by: { $0.type ?? "未分类" })
        return groups.keys.sorted().map { key in
            SectionData(title: key, items: groups[key] ?? [])
        }
    }
    
    var availableTags: [String] {
        let all = allQuestions.compactMap { $0.tags }
        let parts = all.flatMap { $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) } }
        return Array(Set(parts)).sorted()
    }
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    // MARK: - User Actions
    
    func deleteQuestion(_ question: Question) {
        guard let id = question.id else { return }
        
        // Optimistic UI Update
        if let index = questions.firstIndex(of: question) {
            questions.remove(at: index)
        }
        if let index = allQuestions.firstIndex(of: question) {
            allQuestions.remove(at: index)
        }
        
        // Call API
        Task {
            do {
                try await service.deleteQuestion(question)
                // Show Snackbar
                withAnimation {
                    self.snackbarMessage = NSLocalizedString("delete_success_message", comment: "")
                }
                // Auto hide snackbar
                try await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation {
                    self.snackbarMessage = nil
                }
            } catch {
                // Rollback if needed (simplified here)
                self.error = .databaseError(error.localizedDescription, UUID())
                // In production, we should restore the deleted item here
                self.loadData() // Reload to restore
            }
        }
    }
    
    func toggleSelection(for question: Question) {
        guard let id = question.id else { return }
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
    
    func batchDelete() {
        let idsToDelete = selectedIds
        guard !idsToDelete.isEmpty else { return }
        
        // Find questions objects to delete before removing from UI
        let questionsToDelete = allQuestions.filter { q in
            guard let id = q.id else { return false }
            return idsToDelete.contains(id)
        }
        
        // Optimistic UI Update
        let remainingQuestions = allQuestions.filter { q in
            guard let id = q.id else { return true }
            return !idsToDelete.contains(id)
        }
        
        withAnimation {
            allQuestions = remainingQuestions
            filterQuestions(text: searchText, type: selectedType)
            isMultiSelectionMode = false
            selectedIds.removeAll()
        }
        
        // Perform deletion in background
        Task {
            do {
                // In a real app with backend, use a batch delete API: POST /api/questions/batch_delete { ids: [...] }
                // Here we loop through local service
                for question in questionsToDelete {
                    try await service.deleteQuestion(question)
                }
                
                // Show success
                await MainActor.run {
                    withAnimation {
                        self.snackbarMessage = NSLocalizedString("delete_success_message", comment: "")
                    }
                }
                
                // Auto hide snackbar
                try await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    withAnimation {
                        self.snackbarMessage = nil
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = .databaseError(error.localizedDescription, UUID())
                    // Ideally revert UI changes here by reloading
                    self.loadData()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func isSelected(_ question: Question) -> Bool {
        guard let id = question.id else { return false }
        return selectedIds.contains(id)
    }
    
    func refresh() {
        loadData()
    }
}
