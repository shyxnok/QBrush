//
//  Color.swift
//  QBrush
//
//  Created by bgcode on 2026/2/2.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

extension Color {
    static var groupedBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }

    static var systemGray5: Color {
        #if canImport(UIKit)
        if #available(iOS 13.0, *) {
            return Color(UIColor.systemGray5)
        } else {
            return Color.gray.opacity(0.1)
        }
        #elseif canImport(AppKit)
        return Color(NSColor.gray.withAlphaComponent(0.1))
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
    
    static var systemBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.05)
        #endif
    }
    
    static var secondarySystemGroupedBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.05)
        #endif
    }
}
