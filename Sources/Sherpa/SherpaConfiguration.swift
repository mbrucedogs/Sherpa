//
//  SherpaConfiguration.swift
//  Sherpa
//
//  Configuration options for customizing the walkthrough appearance and behavior.
//

import SwiftUI

/// Configuration options for customizing the Sherpa walkthrough experience
public struct SherpaConfiguration: Sendable {
    
    // MARK: - Spotlight Appearance
    
    /// Padding around the focused element
    public var spotlightPadding: CGFloat
    
    /// Corner radius of the spotlight cutout
    public var spotlightCornerRadius: CGFloat
    
    /// Color of the highlight ring around the focused element
    public var highlightColor: Color
    
    /// Width of the highlight ring
    public var highlightWidth: CGFloat
    
    /// Whether to show the highlight ring
    public var showHighlightRing: Bool
    
    // MARK: - Overlay Appearance
    
    /// The overlay color that dims the background
    public var overlayColor: Color
    
    // MARK: - Animation & Timing
    
    /// Duration of transitions between steps (seconds)
    public var transitionDuration: TimeInterval
    
    /// Delay before starting the walkthrough after view appears (seconds)
    public var startDelay: TimeInterval
    
    /// Delay between step transitions (seconds)
    public var stepTransitionDelay: TimeInterval
    
    // MARK: - Haptic Feedback
    
    /// Whether to play haptic feedback on step changes
    public var hapticsEnabled: Bool
    
    /// The haptic feedback style
    public var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    // MARK: - Progress Indicator
    
    /// Whether to show the progress indicator
    public var showProgressIndicator: Bool
    
    /// Position of the progress indicator
    public var progressIndicatorPosition: ProgressPosition
    
    // MARK: - Accessibility
    
    /// Whether to announce step changes via VoiceOver
    public var announceStepsForAccessibility: Bool
    
    // MARK: - Initialization
    
    public init(
        spotlightPadding: CGFloat = Design.Spotlight.padding,
        spotlightCornerRadius: CGFloat = Design.Spotlight.cornerRadius,
        highlightColor: Color = Color.Sherpa.highlight,
        highlightWidth: CGFloat = Design.LineWidth.medium,
        showHighlightRing: Bool = true,
        overlayColor: Color = Color.Sherpa.overlay,
        transitionDuration: TimeInterval = Design.Animation.medium,
        startDelay: TimeInterval = Design.Animation.slow + 0.1,
        stepTransitionDelay: TimeInterval = Design.Animation.medium,
        hapticsEnabled: Bool = true,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        showProgressIndicator: Bool = false,
        progressIndicatorPosition: ProgressPosition = .bottom,
        announceStepsForAccessibility: Bool = true
    ) {
        self.spotlightPadding = spotlightPadding
        self.spotlightCornerRadius = spotlightCornerRadius
        self.highlightColor = highlightColor
        self.highlightWidth = highlightWidth
        self.showHighlightRing = showHighlightRing
        self.overlayColor = overlayColor
        self.transitionDuration = transitionDuration
        self.startDelay = startDelay
        self.stepTransitionDelay = stepTransitionDelay
        self.hapticsEnabled = hapticsEnabled
        self.hapticStyle = hapticStyle
        self.showProgressIndicator = showProgressIndicator
        self.progressIndicatorPosition = progressIndicatorPosition
        self.announceStepsForAccessibility = announceStepsForAccessibility
    }
    
    /// Default configuration
    public static let `default` = SherpaConfiguration()
    
    /// A minimal configuration with no extra UI elements
    public static let minimal = SherpaConfiguration(
        showHighlightRing: false,
        overlayColor: Color.Sherpa.overlayMinimal,
        hapticsEnabled: false
    )
    
    /// A bold configuration with stronger visual emphasis
    public static let bold = SherpaConfiguration(
        spotlightPadding: 16,
        spotlightCornerRadius: 20,
        highlightColor: Color.Sherpa.highlightBold,
        highlightWidth: 4,
        overlayColor: Color.Sherpa.overlayBold
    )
}

// MARK: - Supporting Types

public enum ProgressPosition: Sendable {
    case top
    case bottom
}
