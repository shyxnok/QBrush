import SwiftUI
import Combine

/// 控制器层 (ViewModel) - 连接 UI 与 Service
/// 负责管理 UI 状态和处理用户意图
@MainActor
class QuestionListViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // 筛选状态
    @Published var searchText: String = ""
    @Published var selectedType: String? = nil
    
    private let service: QuestionService
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    
    init(service: QuestionService = QuestionService()) {
        self.service = service
        setupBindings()
        loadQuestions()
    }
    
    private func setupBindings() {
        // 监听搜索和筛选变化，自动刷新列表
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentPage = 1
                self.loadQuestions()
            }
            .store(in: &cancellables)
            
        $selectedType
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentPage = 1
                self.loadQuestions()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Intent (API Interface)
    
    /// 加载题目列表
    func loadQuestions() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let data = try await service.getQuestionList(page: currentPage, type: selectedType, keyword: searchText)
                self.questions = data
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    /// 删除题目
    func deleteQuestion(_ question: Question) {
        Task {
            do {
                try await service.deleteQuestion(question)
                if let index = self.questions.firstIndex(of: question) {
                    self.questions.remove(at: index)
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func refresh() {
        currentPage = 1
        loadQuestions()
    }
    
    func loadMore() {
        currentPage += 1
        // 实际项目应 append 到 questions 数组，这里暂未实现分页追加逻辑
        // loadQuestions()
    }
}
