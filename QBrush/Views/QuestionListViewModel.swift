import SwiftUI
import Combine

/// 控制器层 (ViewModel) - 连接 UI 与 Service
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
                self?.currentPage = 1
                self?.loadQuestions()
            }
            .store(in: &cancellables)
            
        $selectedType
            .sink { [weak self] _ in
                self?.currentPage = 1
                self?.loadQuestions()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Intent (API Interface)
    
    func loadQuestions() {
        isLoading = true
        errorMessage = nil
        
        let result = service.getQuestionList(page: currentPage, type: selectedType, keyword: searchText)
        
        DispatchQueue.main.async {
            self.isLoading = false
            switch result {
            case .success(let data):
                self.questions = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteQuestion(_ question: Question) {
        let result = service.deleteQuestion(question)
        switch result {
        case .success:
            if let index = questions.firstIndex(of: question) {
                questions.remove(at: index)
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func refresh() {
        currentPage = 1
        loadQuestions()
    }
    
    func loadMore() {
        currentPage += 1
        // 这里需要修改 Service 支持 append 模式，或者直接 fetch next page
        // 简单起见，当前 Demo 假设 loadQuestions 会覆盖。
        // 实际项目应 append 到 questions 数组
        // self.loadQuestions() 
    }
}
