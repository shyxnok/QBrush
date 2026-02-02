//
//  QuestionCRUDTests.swift
//  QBrushTests
//
//  Created by bgcode on 2026/2/1.
//

import XCTest
import CoreData
@testable import QBrush

final class QuestionCRUDTests: XCTestCase {
    
    var repository: QuestionRepository!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        // 使用共享的持久化控制器，以便数据写入真实数据库文件
        // 这样用户在运行完测试后，打开 App 可以看到数据
        let persistenceController = PersistenceController.shared
        context = persistenceController.container.viewContext
        repository = QuestionRepository(context: context)
    }
    
    override func tearDownWithError() throws {
        repository = nil
        context = nil
    }
    
    func testCRUD_Workflow() async throws {
        print("🚀 开始测试 Create...")
        
        // 1. Create (增)
        let content = "这是一个测试题目 \(Date())"
        let type = "选择题"
        let difficulty = "中等"
        let newQuestion = try await repository.create(content: content, 
                                            type: type, 
                                            difficulty: difficulty, 
                                            options: "A,B,C,D", 
                                            correctAnswer: "A", 
                                            analysis: "这是解析", 
                                            tags: "测试")
        
        XCTAssertNotNil(newQuestion.id, "创建失败：ID为空")
        XCTAssertEqual(newQuestion.content, content, "创建失败：内容不一致")
        print("✅ Create 成功: \(newQuestion.id!)")
        
        // 2. Read (查)
        print("🚀 开始测试 Read...")
        let fetchedQuestion = try await repository.getById(id: newQuestion.id!)
        XCTAssertNotNil(fetchedQuestion, "查询失败：未找到数据")
        XCTAssertEqual(fetchedQuestion?.content, content, "查询失败：内容不一致")
        print("✅ Read 成功")
        
        // 3. Update (改)
        print("🚀 开始测试 Update...")
        let updatedContent = "测试题目(已更新) \(Date())"
        let updatedQuestion = try await repository.update(question: newQuestion, content: updatedContent, correctAnswer: "B")
        
        XCTAssertEqual(updatedQuestion.content, updatedContent, "更新失败：内容未变更")
        XCTAssertEqual(updatedQuestion.correctAnswer, "B", "更新失败：答案未变更")
        
        // 验证数据库中确实更新了
        let reFetchedQuestion = try await repository.getById(id: newQuestion.id!)
        XCTAssertEqual(reFetchedQuestion?.content, updatedContent, "持久化验证失败：数据库值未更新")
        print("✅ Update 成功: \(updatedQuestion.content ?? "")")
        
        // 4. Delete (删除)
        // 注意：为了让用户在 App 中看到数据，我们这里可以创建第二条数据用来删除，保留第一条
        print("🚀 开始测试 Delete...")
       let questionToDelete = try await repository.create(content: "待删除题目", type: "填空题", difficulty: "简单")
       XCTAssertNotNil(questionToDelete.id)
       let deletedId = questionToDelete.id!
       
       try await repository.delete(question: questionToDelete)
       
       let deletedFetch = try await repository.getById(id: deletedId)
       XCTAssertNil(deletedFetch, "删除失败：数据仍然存在")
        print("✅ Delete 成功: 数据已移除")
        
        // 5. 最终验证
        // 此时数据库中应该保留了 `updatedQuestion`，用户打开 App 可以看到它
        print("🎉 所有 CRUD 测试通过！请打开 App 查看标题包含 '测试题目(已更新)' 的数据。")
    }

    func testGetAllWithFiltersAndPagination() throws {
        // 0. 清理环境，确保测试独立性
        try repository.deleteAll()
        
        // 1. 准备测试数据 (插入 30 条不同类型的数据)
        // 10 条选择题 (简单)
        for i in 1...10 {
            _ = try repository.create(content: "选择题 \(i) - 关键词A", type: "选择题", difficulty: "简单")
        }
        // 10 条填空题 (中等)
        for i in 1...10 {
            _ = try repository.create(content: "填空题 \(i) - 关键词B", type: "填空题", difficulty: "中等")
        }
        // 10 条判断题 (困难)
        for i in 1...10 {
            _ = try repository.create(content: "判断题 \(i) - 关键词A", type: "判断题", difficulty: "困难")
        }
        
        print("✅ 准备了 30 条测试数据")
        
        // 2. 测试分页 (Page Size = 20)
        // 第一页应该有 20 条
        let page1 = try repository.getAll(page: 1, pageSize: 20)
        XCTAssertEqual(page1.count, 20, "分页测试失败：第一页数量不对")
        
        // 第二页应该有 10 条 (总共 30 条)
        let page2 = try repository.getAll(page: 2, pageSize: 20)
        XCTAssertEqual(page2.count, 10, "分页测试失败：第二页数量不对")
        
        print("✅ 分页测试通过")
        
        // 3. 测试类型筛选 (Type = "选择题")
        let choiceQuestions = try repository.getAll(pageSize: 100, type: "选择题")
        XCTAssertEqual(choiceQuestions.count, 10, "类型筛选失败：数量不对")
        XCTAssertTrue(choiceQuestions.allSatisfy { $0.type == "选择题" }, "类型筛选失败：包含非选择题")
        
        print("✅ 类型筛选测试通过")
        
        // 4. 测试难度筛选 (Difficulty = "困难")
        let hardQuestions = try repository.getAll(pageSize: 100, difficulty: "困难")
        XCTAssertEqual(hardQuestions.count, 10, "难度筛选失败：数量不对")
        XCTAssertTrue(hardQuestions.allSatisfy { $0.difficulty == "困难" }, "难度筛选失败：包含非困难题")
        
        print("✅ 难度筛选测试通过")
        
        // 5. 测试关键词搜索 (Keyword = "关键词A")
        // 应该包含 10 条选择题 + 10 条判断题 = 20 条
        let keywordQuestions = try repository.getAll(pageSize: 100, keyword: "关键词A")
        XCTAssertEqual(keywordQuestions.count, 20, "关键词搜索失败：数量不对")
        
        print("✅ 关键词搜索测试通过")
        
        // 6. 测试组合筛选 (Type = "选择题" AND Keyword = "关键词A")
        let combinedQuestions = try repository.getAll(pageSize: 100, type: "选择题", keyword: "关键词A")
        XCTAssertEqual(combinedQuestions.count, 10, "组合筛选失败：数量不对")
        
        print("✅ 组合筛选测试通过")
    }
}
