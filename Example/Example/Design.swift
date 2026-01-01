//
//  Design.swift
//  Example
//
//  Design constants for the Example app.
//

import SwiftUI

// MARK: - Design Constants

enum AppDesign {
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
        static let xxxLarge: CGFloat = 32
        static let xxxxLarge: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    // MARK: - Opacity
    
    enum Opacity {
        static let subtle: Double = 0.1
        static let hint: Double = 0.2
        static let light: Double = 0.3
        static let medium: Double = 0.5
        static let strong: Double = 0.7
        static let heavy: Double = 0.8
    }
    
    // MARK: - Size
    
    enum Size {
        static let iconSmall: CGFloat = 40
        static let iconMedium: CGFloat = 60
        static let iconLarge: CGFloat = 80
        static let iconXLarge: CGFloat = 100
        static let iconXXLarge: CGFloat = 120
        static let buttonMinHeight: CGFloat = 44
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick: Double = 0.15
        static let standard: Double = 0.25
        static let medium: Double = 0.3
    }
}

// MARK: - App Colors

extension Color {
    enum App {
        static let primary = Color.blue
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        static let purple = Color.purple
        
        static let cardBackground = Color(uiColor: .secondarySystemBackground)
        static let logBackground = Color.black.opacity(0.9)
        static let logText = Color.green
    }
}
