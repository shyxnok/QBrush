//
//  QuestionRowView.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import SwiftUI

struct QuestionRowView: View {
    let question: Question
    let searchText: String
    let isSelected: Bool
    let isMultiSelectionMode: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection Checkbox
            if isMultiSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .font(.system(size: 22))
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Content with Highlight
                if #available(iOS 15.0, *) {
                    Text(attributedString(for: question.content ?? "", highlight: searchText))
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility3) // Limit dynamic type scaling
                } else {
                    Text(question.content ?? "")
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    // Type Badge
                    Text(LocalizedStringKey("filter_" + mapTypeToKey(question.type)))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(6)
                    
                    // Difficulty Stars
                    if let difficulty = question.difficulty {
                        HStack(spacing: 2) {
                            ForEach(0..<starCount(for: difficulty), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Date
                    if let date = question.createdAt {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelString)
    }
    
    // MARK: - Helpers
    
    private func starCount(for difficulty: String) -> Int {
        switch difficulty {
        case "简单": return 1
        case "中等": return 2
        case "困难": return 3
        default: return 1
        }
    }
    
    private func mapTypeToKey(_ type: String?) -> String {
        switch type {
        case "选择题": return "choice"
        case "填空题": return "fill"
        case "判断题": return "judgment"
        case "解答题": return "answer"
        default: return "all"
        }
    }
    
    @available(iOS 15, *)
    private func attributedString(for text: String, highlight: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        guard !highlight.isEmpty else { return attributed }
        
        if let range = attributed.range(of: highlight, options: .caseInsensitive) {
            attributed[range].foregroundColor = .orange
            attributed[range].font = .body.bold()
        }
        
        return attributed
    }
    
    private var accessibilityLabelString: String {
        let content = question.content ?? "Unknown content"
        let type = question.type ?? "Unknown type"
        return "\(type), \(content)"
    }
}
