//
//  Localization.swift
//  Sherpa
//
//  Localization support for the Sherpa framework.
//

import SwiftUI

// MARK: - Localized Strings

/// Namespace for accessing Sherpa's localized strings
public enum SherpaStrings {
    
    // MARK: - UI Strings (LocalizedStringKey for SwiftUI Text views)
    
    /// "Skip" button text
    public static var skip: LocalizedStringKey { "sherpa.skip" }
    
    /// "Done" button text
    public static var done: LocalizedStringKey { "sherpa.done" }
    
    /// "Ok!" confirmation text
    public static var ok: LocalizedStringKey { "sherpa.ok" }
    
    // MARK: - Accessibility (LocalizedStringKey)
    
    /// "Skip walkthrough" accessibility label
    public static var accessibilitySkipWalkthrough: LocalizedStringKey { "sherpa.accessibility.skip_walkthrough" }
    
    /// "Double tap to skip the remaining steps" accessibility hint
    public static var accessibilitySkipHint: LocalizedStringKey { "sherpa.accessibility.skip_hint" }
    
    /// "Previous step" accessibility label
    public static var accessibilityPreviousStep: LocalizedStringKey { "sherpa.accessibility.previous_step" }
    
    /// "Next step" accessibility label
    public static var accessibilityNextStep: LocalizedStringKey { "sherpa.accessibility.next_step" }
    
    /// "Complete walkthrough" accessibility label
    public static var accessibilityCompleteWalkthrough: LocalizedStringKey { "sherpa.accessibility.complete_walkthrough" }
    
    // MARK: - Dynamic Strings (String for programmatic use)
    
    /// Returns localized "Step X of Y" string for accessibility announcements
    public static func stepOf(current: Int, total: Int) -> String {
        String(localized: "Step \(current) of \(total)", table: nil, bundle: .module, comment: "Accessibility announcement for current step")
    }
}

// MARK: - Text Extension for Sherpa Bundle

extension Text {
    /// Creates a Text view with a localized string from the Sherpa bundle
    init(sherpa key: LocalizedStringKey) {
        self.init(key, bundle: .module)
    }
}

// MARK: - Callout Localization Support

extension Callout {
    
    /// Creates a localized text callout using the app's string catalog
    /// - Parameters:
    ///   - key: The localization key from your app's Localizable.xcstrings
    ///   - edge: Which edge of the element to show the callout (default: .top)
    ///   - bundle: The bundle containing the localization (default: .main)
    public static func localizedText(
        _ key: LocalizedStringKey,
        edge: Edge = .top,
        bundle: Bundle = .main
    ) -> Self {
        .bubble(edge: edge) {
            Text(key, bundle: bundle)
        }
    }
    
    /// Creates a localized text callout with an "Ok!" button
    /// - Parameters:
    ///   - key: The localization key from your app's Localizable.xcstrings
    ///   - edge: Which edge of the element to show the callout (default: .top)
    ///   - bundle: The bundle containing the localization (default: .main)
    public static func localizedOkText(
        _ key: LocalizedStringKey,
        edge: Edge = .top,
        bundle: Bundle = .main
    ) -> Self {
        .bubble(edge: edge) {
            HStack {
                Text(key, bundle: bundle)
                    .padding(.trailing, Design.Spacing.xSmall)
                Color.black.frame(width: Design.LineWidth.thin)
                Text(sherpa: SherpaStrings.ok)
                    .bold()
                    .padding(.leading, Design.Spacing.xSmall)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    /// Creates a localized callout with an icon and text
    /// - Parameters:
    ///   - key: The localization key from your app's Localizable.xcstrings
    ///   - systemImage: SF Symbol name
    ///   - edge: Which edge of the element to show the callout (default: .top)
    ///   - bundle: The bundle containing the localization (default: .main)
    public static func localizedLabeled(
        _ key: LocalizedStringKey,
        systemImage: String,
        edge: Edge = .top,
        bundle: Bundle = .main
    ) -> Self {
        .bubble(edge: edge) {
            Label {
                Text(key, bundle: bundle)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
}
