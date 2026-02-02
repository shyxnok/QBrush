import Foundation

enum QuestionError: Error, LocalizedError {
    case emptyContent
    case invalidType
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyContent: return "题目内容不能为空"
        case .invalidType: return "无效的题目类型"
        case .databaseError(let msg): return "数据库错误: \(msg)"
        }
    }
}

/// 业务逻辑层 (Service) - 处理数据验证、业务规则
class QuestionService {
    private let repository: QuestionRepository
    
    init(repository: QuestionRepository = QuestionRepository()) {
        self.repository = repository
    }
    
    // MARK: - Business Logic
    
    func addQuestion(content: String, 
                     type: String, 
                     language: String = "汉语", 
                     difficulty: String = "中等", 
                     options: String? = nil, 
                     correctAnswer: String? = nil, 
                     analysis: String? = nil, 
                     tags: String? = nil) throws -> Question {
        
        // 1. 数据验证
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw QuestionError.emptyContent
        }
        
        // 2. 调用 DAO
        do {
            return try repository.create(content: content, 
                                       type: type, 
                                       language: language, 
                                       difficulty: difficulty, 
                                       options: options, 
                                       correctAnswer: correctAnswer, 
                                       analysis: analysis, 
                                       tags: tags)
        } catch {
            throw QuestionError.databaseError(error.localizedDescription)
        }
    }
    
    func getQuestionList(page: Int, type: String?, keyword: String?) -> Result<[Question], QuestionError> {
        do {
            let questions = try repository.getAll(page: page, type: type, keyword: keyword)
            return .success(questions)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func updateQuestion(_ question: Question, content: String, correctAnswer: String?) -> Result<Question, QuestionError> {
        guard !content.isEmpty else { return .failure(.emptyContent) }
        
        do {
            let updated = try repository.update(question: question, content: content, correctAnswer: correctAnswer)
            return .success(updated)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func deleteQuestion(_ question: Question) -> Result<Void, QuestionError> {
        do {
            try repository.delete(question: question)
            return .success(())
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
}
