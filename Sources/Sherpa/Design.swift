//
//  Design.swift
//  Sherpa
//
//  Design constants for consistent styling across the framework.
//

import SwiftUI

// MARK: - Design Constants

public enum Design {
    
    // MARK: - Spacing
    
    public enum Spacing {
        public static let xxSmall: CGFloat = 2
        public static let xSmall: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let xLarge: CGFloat = 20
        public static let xxLarge: CGFloat = 24
        public static let xxxLarge: CGFloat = 32
        public static let safeArea: CGFloat = 50
    }
    
    // MARK: - Corner Radius
    
    public enum CornerRadius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let xLarge: CGFloat = 20
    }
    
    // MARK: - Opacity
    
    public enum Opacity {
        public static let subtle: Double = 0.1
        public static let hint: Double = 0.2
        public static let light: Double = 0.3
        public static let disabled: Double = 0.3
        public static let medium: Double = 0.5
        public static let accent: Double = 0.6
        public static let strong: Double = 0.7
        public static let heavy: Double = 0.8
        public static let almostFull: Double = 0.9
    }
    
    // MARK: - Line Width
    
    public enum LineWidth {
        public static let thin: CGFloat = 1
        public static let medium: CGFloat = 2
        public static let thick: CGFloat = 3
    }
    
    // MARK: - Shadow
    
    public enum Shadow {
        public static let radiusSmall: CGFloat = 2
        public static let radiusMedium: CGFloat = 4
        public static let radiusLarge: CGFloat = 8
        public static let offsetSmall: CGFloat = 1
        public static let offsetMedium: CGFloat = 4
    }
    
    // MARK: - Animation
    
    public enum Animation {
        public static let quick: Double = 0.15
        public static let standard: Double = 0.25
        public static let medium: Double = 0.3
        public static let slow: Double = 0.4
        public static let stepTransition: Double = 0.3
        public static let stepTransitionDelay: Int = 300
    }
    
    // MARK: - Size
    
    public enum Size {
        public static let iconSmall: CGFloat = 6
        public static let iconMedium: CGFloat = 8
        public static let buttonMinHeight: CGFloat = 44
        public static let progressDotSmall: CGFloat = 6
        public static let progressDotLarge: CGFloat = 8
        public static let calloutPointerWidth: CGFloat = 12
        public static let calloutPointerHeight: CGFloat = 8
        public static let calloutCornerRadius: CGFloat = 10
    }
    
    // MARK: - Spotlight
    
    public enum Spotlight {
        public static let padding: CGFloat = 8
        public static let cornerRadius: CGFloat = 12
        public static let highlightWidth: CGFloat = 2
        public static let boldPadding: CGFloat = 12
        public static let boldCornerRadius: CGFloat = 16
        public static let boldHighlightWidth: CGFloat = 3
    }
}

// MARK: - Semantic Colors

extension Color {
    
    public enum Sherpa {
        /// Default overlay color for dimming the background
        public static let overlay = Color.black.opacity(0.6)
        
        /// Overlay color for bold configuration - much darker
        public static let overlayBold = Color.black.opacity(0.85)
        
        /// Overlay color for minimal configuration - much lighter
        public static let overlayMinimal = Color.black.opacity(0.3)
        
        /// Highlight ring color
        public static let highlight = Color.white.opacity(0.5)
        
        /// Highlight ring color for bold configuration - bright and prominent
        public static let highlightBold = Color.white
        
        /// Callout background
        public static let calloutBackground = Color.white
        
        /// Callout text color - ensures readability on white background
        public static let calloutText = Color.black
        
        /// Callout pressed state
        public static let calloutPressed = Color(white: 0.9)
        
        /// Callout shadow
        public static let calloutShadow = Color.black.opacity(0.15)
    }
}
