import Foundation

/// 业务逻辑层 (Service) - 处理数据验证、业务规则
/// 负责协调 ViewModel 与 Repository 之间的交互
class QuestionService {
    private let repository: QuestionRepository
    
    init(repository: QuestionRepository = QuestionRepository()) {
        self.repository = repository
    }
    
    // MARK: - Business Logic
    
    /// 添加新题目
    func addQuestion(content: String, 
                     qtype: String,
                     difficulty: String = "中等",
                     options: String? = nil, 
                     correctAnswer: String? = nil, 
                     analysis: String? = nil,
                     type: String? = nil,
                     createdBy: String? = nil,
                     tags: String? = nil) async throws -> Question {
        
        // 1. 数据验证
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw QuestionError.emptyContent
        }
        
        // 2. 调用 DAOcontent: String,
//        qtype: String,
//        difficulty: String,
//        options: String? = nil,
//        correctAnswer: String? = nil,
//        analysis: String? = nil,
//        type: String? = nil,
//        createdBy: String? = nil,
//        tags: String? = nil
        do {
            return try await repository.create(content: content, qtype: qtype,
                                             
                                             difficulty: difficulty,
                                             options: options, 
                                             correctAnswer: correctAnswer, 
                                             analysis: analysis,
                                               type: type,
                                               createdBy:createdBy,
                                             tags: tags)
        } catch {
            throw QuestionError.databaseError(error.localizedDescription)
        }
    }
    
    /// 获取题目列表
    func getQuestionList(page: Int, type: String?, keyword: String?) async throws -> [Question] {
        do {
            return try await repository.getAll(page: page, type: type, keyword: keyword)
        } catch {
            throw QuestionError.databaseError(error.localizedDescription)
        }
    }
    
    /// 更新题目
    func updateQuestion(_ question: Question, content: String, correctAnswer: String?) async throws -> Question {
        guard !content.isEmpty else {
            throw QuestionError.emptyContent
        }
        
        do {
            return try await repository.update(question: question, content: content, correctAnswer: correctAnswer)
        } catch {
            throw QuestionError.databaseError(error.localizedDescription)
        }
    }
    
    /// 删除题目
    func deleteQuestion(_ question: Question) async throws {
        do {
            try await repository.delete(question: question)
        } catch {
            throw QuestionError.databaseError(error.localizedDescription)
        }
    }
}
