//
//  ContentView.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @State private var totalQuestions: Int = 0
    @State private var practiced: Int = 0
    @State private var accuracy: Double = 0
    @State private var wrongCount: Int = 0

    var body: some View {
        // 兼容macOS/iOS的导航容器
        if #available(iOS 16.0, macOS 13.0, *) {
            NavigationStack {
                mainContent
                    .navigationTitle("QBrush")
            }
        } else {
            NavigationView {
                mainContent
                    .navigationTitle("QBrush")
            }
        }
    }

    // 抽离主内容，避免重复代码
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                metricsSection
                quickActionsSection
                progressSection
            }
            .padding(16)
        }
        .background(Color.groupedBackground)  // 使用跨平台分组背景色
    }

    private var metricsSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 12
        ) {
            StatsCard(
                title: "题库总量", valueText: "\(totalQuestions)", footnote: "道题目",
                icon: "books.vertical")
            StatsCard(title: "已练习", valueText: "\(practiced)", footnote: "道题目", icon: "bolt")
            StatsCard(
                title: "正确率", valueText: String(format: "%.1f%%", accuracy * 100),
                footnote: "答题准确率", icon: "chart.bar")
            StatsCard(
                title: "错题数量", valueText: "\(wrongCount)", footnote: "待复习",
                icon: "exclamationmark.circle")
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快捷操作")
                .font(.headline)
                .foregroundColor(.primary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                QuickActionCard(
                    title: "题库管理", subtitle: "查看和管理题目", icon: "book",
                    color: .blue, destination: {
                        QuestionManagementView() // 跳转目标页面
                   }
                )
                QuickActionCard(
                    title: "导入题目", subtitle: "批量导入新题目", icon: "square.and.arrow.down.on.square",
                    color: .green, destination: {
                        QView() // 跳转目标页面
                    }
                )
                QuickActionCard(
                    title: "记忆力测试", subtitle: "评估记忆力水平", icon: "brain.head.profile", color: .teal, destination: {
                        QView() // 跳转目标页面
                    }
                )
                QuickActionCard(
                    title: "智能刷题", subtitle: "开始个性化练习", icon: "bolt.fill", color: .yellow, destination: {
                        QView() // 跳转目标页面
                    }
                )
                QuickActionCard(
                    title: "错题本", subtitle: "复习错题", icon: "exclamationmark.bubble", color: .red, destination: {
                        QView() // 跳转目标页面
                    }
                )
                QuickActionCard(
                    title: "学习统计", subtitle: "查看学习数据", icon: "chart.bar.fill", color: .orange, destination: {
                        QView() // 跳转目标页面
                    }
                ) 
            }
        }
    }

    private var progressSection: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("学习进度")
                    .font(.headline)
                Text("您的学习数据概览")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Divider()
                LazyVGrid(columns: [
                    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
                ]) {
                    progressItem(title: "题库完成度", value: "\(Int(accuracy * 100))%")
                    progressItem(title: "累计练习时长", value: "0分钟")
                    progressItem(title: "已掌握错题", value: "\(wrongCount)道")
                }
            }
        }
    }

    private func progressItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

extension Color {
    /// 跨平台分组背景色（iOS: systemGroupedBackground，macOS: controlBackgroundColor）
    static var groupedBackground: Color {
        #if os(iOS) || os(tvOS) || os(watchOS)
            return Color(UIColor.systemGroupedBackground)
        #elseif os(macOS)
            return Color(NSColor.controlBackgroundColor)
        #else
            return Color.gray.opacity(0.1)
        #endif
    }

    /// 跨平台等效于iOS systemGray5的灰度颜色（适配iOS/macOS）
    static var systemGray5: Color {
        #if os(iOS) || os(tvOS) || os(watchOS)
            // iOS直接使用systemGray5
            if #available(iOS 13.0, *) {
                return Color(UIColor.systemGray5)
            } else {
                return Color.gray.opacity(0.1)
            }
        #elseif os(macOS)
            // macOS无systemGray5，用自定义灰度替代（视觉最接近iOS的systemGray5）
            return Color(NSColor.gray.withAlphaComponent(0.1))
        #else
            // 其他平台降级
            return Color.gray.opacity(0.1)
        #endif
    }
}

#Preview {
    ContentView()
}
