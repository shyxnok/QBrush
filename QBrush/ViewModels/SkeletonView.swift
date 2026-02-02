//
//  SkeletonView.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import SwiftUI

struct SkeletonRow: View {
    @State private var blink = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Type Badge Skeleton
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.1))
                .frame(width: 44, height: 24)
            
            VStack(alignment: .leading, spacing: 8) {
                // Title Skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                
                // Subtitle Skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 12)
                    .frame(width: 120)
            }
        }
        .padding(.vertical, 12)
        .opacity(blink ? 0.3 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: blink)
        .onAppear {
            blink = true
        }
    }
}

struct SkeletonListView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { _ in
                    SkeletonRow()
                        .padding(.horizontal)
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .disabled(true) // Disable interaction
    }
}

#Preview {
    SkeletonListView()
}
