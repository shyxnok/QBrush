//
//  Untitled.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//
import SwiftUI


struct StatsCard: View {
    let title: String
    let valueText: String
    let footnote: String
    let icon: String
    
    var body: some View {
        SectionCard {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(valueText)
                        .font(.title2)
                        .foregroundColor(.primary)
                    Text(footnote)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
    }
}

import SwiftUI

struct QuickActionCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: Destination // 跳转目标页面
    let isNavigationEnabled: Bool // 是否启用卡片跳转（默认true）
    
    init(
         title: String,
         subtitle: String,
         icon: String = "square.and.pencil",
         color: Color,
         @ViewBuilder destination: () -> Destination,
         isNavigationEnabled: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.destination = destination()
        self.isNavigationEnabled = isNavigationEnabled
    }
    
    private var cardContent: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1) // 修正颜色常量
        )
    }
    
    var body: some View {
        if isNavigationEnabled {
            // 包裹NavigationLink实现跳转
            NavigationLink {
                destination
            } label: {
                cardContent
                    .foregroundColor(.primary) // 移除NavigationLink默认的蓝色
            }
            .buttonStyle(PlainButtonStyle()) // 使用正确的按钮样式
        } else {
            // 不启用跳转，直接显示卡片
            cardContent
        }
    }
}

struct SectionCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.systemGray5, lineWidth: 1) // 使用跨平台systemGray5
        )
    }
}


#Preview {
    QuickActionCard(
        title: "题库管理", subtitle: "查看和管理题目", icon: "book",
        color: .blue, destination: {
        QView() // 跳转目标页面
       },isNavigationEnabled: true
    )
//    StatsCard(title: "题库总量", valueText: "\(33)", footnote: "道题目", icon: "books.vertical")
}

