//
//  QView.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import SwiftUI

struct QView: View {
    var body: some View {
        VStack {
            Image(systemName: "hammer")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("功能开发中...")
                .font(.title)
                .foregroundColor(.gray)
                .padding()
        }
        .navigationTitle("QBrush")
    }
}

#Preview {
    QView()
}
