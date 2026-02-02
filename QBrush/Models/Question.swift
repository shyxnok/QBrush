//
//  Question.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

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

// 题目类型枚举
enum QuestionType: String, CaseIterable, Identifiable {
    case singleChoice = "选择题"
    case fillBlank = "填空题"
    case judgment = "判断题"
    case answer = "解答题"
    
    var id: Self { self }
}

// 难度枚举（带星级展示）
enum QuestionDifficulty: String, CaseIterable, Identifiable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"
    
    var id: Self { self }
    var starIcon: String {
        switch self {
        case .easy: return "star"
        case .medium: return "star.fill"
        case .hard: return "star.fill.star.fill"
        }
    }
    var starCount: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}
