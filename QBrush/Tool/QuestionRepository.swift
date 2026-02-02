import Foundation
import CoreData

/// 数据访问层 (DAO) - 负责所有 CoreData 底层操作
/// 封装了对 Question 实体的增删改查逻辑
class QuestionRepository {
    private let context: NSManagedObjectContext
    
    /// 初始化 Repository
    /// - Parameter context: Core Data 上下文，默认为 View Context
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Create
    
    /// 创建新题目
    func create(content: String, 
                qtype: String, 
                difficulty: String, 
                options: String? = nil, 
                correctAnswer: String? = nil, 
                analysis: String? = nil, 
                type: String? = nil,
                createdBy: String? = nil,
                tags: String? = nil) async throws -> Question {
        
        try await context.perform {
            let question = Question(context: self.context)
            question.id = UUID()
            question.content = content
            question.type = type
            question.difficulty = difficulty
            question.options = options
            question.correctAnswer = correctAnswer
            question.analysis = analysis
            question.tags = tags
            question.createdAt = Date()
            question.updatedAt = Date()
            question.createdBy = createdBy ?? "admin"
            question.qtype = qtype
            try self.save()
            return question
        }
    }
    
    // MARK: - Read
    
    /// 获取题目列表
    func getAll(page: Int = 1, 
                pageSize: Int = 20, 
                type: String? = nil, 
                difficulty: String? = nil, 
                keyword: String? = nil) async throws -> [Question] {
        
        try await context.perform {
            let request: NSFetchRequest<Question> = Question.fetchRequest()
            
            // 分页
            request.fetchLimit = pageSize
            request.fetchOffset = (page - 1) * pageSize
            
            // 排序
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            // 筛选条件
            var predicates: [NSPredicate] = []
            
            if let type = type, !type.isEmpty {
                predicates.append(NSPredicate(format: "type == %@", type))
            }
            
            if let difficulty = difficulty, !difficulty.isEmpty {
                predicates.append(NSPredicate(format: "difficulty == %@", difficulty))
            }
            
            if let keyword = keyword, !keyword.isEmpty {
                predicates.append(NSPredicate(format: "content CONTAINS[cd] %@", keyword))
            }
            
            if !predicates.isEmpty {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
            
            return try self.context.fetch(request)
        }
    }
    
    /// 根据 ID 获取题目
    func getById(id: UUID) async throws -> Question? {
        try await context.perform {
            let request: NSFetchRequest<Question> = Question.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try self.context.fetch(request).first
        }
    }
    
    // MARK: - Update
    
    /// 更新题目
    func update(question: Question, 
                content: String? = nil, 
                type: String? = nil, 
                options: String? = nil, 
                correctAnswer: String? = nil,
                analysis: String? = nil,
                tags: String? = nil) async throws -> Question {
        
        try await context.perform {
            if let content = content { question.content = content }
            if let type = type { question.type = type }
            if let options = options { question.options = options }
            if let correctAnswer = correctAnswer { question.correctAnswer = correctAnswer }
            if let analysis = analysis { question.analysis = analysis }
            if let tags = tags { question.tags = tags }
            
            question.updatedAt = Date()
            
            try self.save()
            return question
        }
    }
    
    // MARK: - Delete
    
    /// 删除题目
    func delete(question: Question) async throws {
        try await context.perform {
            self.context.delete(question)
            try self.save()
        }
    }
    
    /// 删除所有题目
    func deleteAll() async throws {
        try await context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Question.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            // 注意：NSBatchDeleteRequest 直接在 Store 层面执行，不会更新 Context 中的对象
            // 需要合并更改或重置 Context
            try self.context.execute(batchDeleteRequest)
            self.context.reset() 
        }
    }
    
    // MARK: - Helper
    
    /// 保存上下文
    /// 注意：此方法应在 perform 块内调用
    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
