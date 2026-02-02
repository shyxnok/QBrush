//
//  QuestionManagementViewModelTests.swift
//  QBrushTests
//
//  Created by bgcode on 2026/2/1.
//

import XCTest
import Combine
import CoreData
@testable import QBrush

final class QuestionManagementViewModelTests: XCTestCase {
    
    var viewModel: QuestionManagementViewModel!
    var mockService: MockQuestionService!
    var cancellables: Set<AnyCancellable>!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        // Setup In-Memory Core Data for creating Question objects
        let persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        
        // Setup Mock Service
        mockService = MockQuestionService(context: context)
        
        // Setup ViewModel
        viewModel = await QuestionManagementViewModel(service: mockService)
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        cancellables = nil
        context = nil
    }
    
    func testLoadData() async throws {
        // Given
        let q1 = createQuestion(content: "Apple", type: "选择题")
        let q2 = createQuestion(content: "Banana", type: "填空题")
        mockService.mockData = [q1, q2]
        
        // When
        await viewModel.loadData()
        
        // Wait for async updates (since loadData uses Future and receive(on: RunLoop.main))
        // We need to wait for the run loop or use expectations
        let expectation = XCTestExpectation(description: "Data Loaded")
        
        viewModel.$questions
            .dropFirst() // Drop initial empty
            .sink { questions in
                if !questions.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(viewModel.questions.count, 2)
        XCTAssertEqual(viewModel.questions.first?.content, "Apple")
    }
    
    func testSearchFilter() async throws {
        // Given
        let q1 = createQuestion(content: "Apple", type: "选择题")
        let q2 = createQuestion(content: "Banana", type: "填空题")
        mockService.mockData = [q1, q2]
        await viewModel.loadData()
        
        // Wait for load
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        await MainActor.run {
            viewModel.searchText = "App"
        }
        
        // Wait for debounce (300ms)
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertEqual(viewModel.questions.count, 1)
        XCTAssertEqual(viewModel.questions.first?.content, "Apple")
    }
    
    func testTypeFilter() async throws {
        // Given
        let q1 = createQuestion(content: "Apple", type: "选择题")
        let q2 = createQuestion(content: "Banana", type: "填空题")
        mockService.mockData = [q1, q2]
        await viewModel.loadData()
        
        // Wait for load
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        await MainActor.run {
            viewModel.selectedType = "填空题"
        }
        
        // Wait for debounce
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertEqual(viewModel.questions.count, 1)
        XCTAssertEqual(viewModel.questions.first?.content, "Banana")
    }
    
    func testDeleteQuestion() async throws {
        // Given
        let q1 = createQuestion(content: "Apple", type: "选择题")
        mockService.mockData = [q1]
        await viewModel.loadData()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        await viewModel.deleteQuestion(q1)
        
        // Wait for animation/async
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertTrue(viewModel.questions.isEmpty)
        XCTAssertTrue(mockService.mockData.isEmpty)
    }
    
    func testBatchDelete() async throws {
        // Given
        let q1 = createQuestion(content: "Apple", type: "选择题")
        let q2 = createQuestion(content: "Banana", type: "填空题")
        let q3 = createQuestion(content: "Cherry", type: "判断题")
        mockService.mockData = [q1, q2, q3]
        await viewModel.loadData()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        await MainActor.run {
            viewModel.isMultiSelectionMode = true
            viewModel.toggleSelection(for: q1)
            viewModel.toggleSelection(for: q2)
        }
        
        await viewModel.batchDelete()
        
        // Wait for task
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertEqual(mockService.mockData.count, 1)
        XCTAssertEqual(mockService.mockData.first?.content, "Cherry")
        XCTAssertFalse(viewModel.isMultiSelectionMode)
    }
    
    // MARK: - Helpers
    
    private func createQuestion(content: String, type: String) -> Question {
        let q = Question(context: context)
        q.id = UUID()
        q.content = content
        q.type = type
        q.createdAt = Date()
        q.updatedAt = Date()
        return q
    }
}

// MARK: - Mocks

class MockQuestionService: QuestionService {
    var mockData: [Question] = []
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init(repository: QuestionRepository(context: context))
    }
    
    override func getQuestionList(page: Int, type: String?, keyword: String?) async throws -> [Question] {
        // Simulate simple filtering
        var result = mockData
        if let type = type {
            result = result.filter { $0.type == type }
        }
        if let keyword = keyword {
            result = result.filter { $0.content?.contains(keyword) == true }
        }
        return result
    }
    
    override func deleteQuestion(_ question: Question) async throws {
        if let index = mockData.firstIndex(of: question) {
            mockData.remove(at: index)
        }
        // Also remove from context to avoid memory leaks in tests
        context.delete(question)
    }
}
