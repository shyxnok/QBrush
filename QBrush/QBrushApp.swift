//
//  QBrushApp.swift
//  QBrush
//
//  Created by bgcode on 2026/2/1.
//

import SwiftUI

@main
struct QBrushApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
