//
//  QuestionRowView.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import SwiftUI
import Foundation

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
                highlightedText(question.content ?? "", highlights: searchTerms)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
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
    
    private var searchTerms: [String] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        return trimmed
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
    }
    
    private func highlightedText(_ text: String, highlights: [String]) -> Text {
        guard !highlights.isEmpty else { return Text(text) }
        let escaped = highlights.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let pattern = "(\(escaped))"
        let options: NSRegularExpression.Options = [.caseInsensitive]
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return Text(text)
        }
        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
        
        var result = Text("")
        var lastLocation = 0
        
        for match in matches {
            let range = match.range
            if range.location > lastLocation {
                let normal = nsText.substring(with: NSRange(location: lastLocation, length: range.location - lastLocation))
                result = result + Text(normal)
            }
            let highlight = nsText.substring(with: range)
            result = result + Text(highlight).foregroundColor(.orange).bold()
            lastLocation = range.location + range.length
        }
        if lastLocation < nsText.length {
            let tail = nsText.substring(with: NSRange(location: lastLocation, length: nsText.length - lastLocation))
            result = result + Text(tail)
        }
        return result
    }
    
    private var accessibilityLabelString: String {
        let content = question.content ?? "Unknown content"
        let type = question.type ?? "Unknown type"
        return "\(type), \(content)"
    }
}
