//
//  ViewExtensions.swift
//  Sherpa
//
//  SwiftUI View extensions for the Sherpa framework.
//

import SwiftUI

// MARK: - View Extensions for Sherpa

extension View {
    
    // MARK: - Core Methods
    
    /// Enables a walkthrough on this view with the specified tags
    /// - Parameters:
    ///   - isActive: Whether the walkthrough should be active
    ///   - tags: The enum type conforming to SherpaTags
    ///   - delegate: Optional delegate for customization and callbacks
    ///   - startDelay: Optional delay before starting (defaults to configuration value)
    public func sherpa<Tags: SherpaTags>(
        isActive: Bool,
        tags: Tags.Type,
        delegate: SherpaDelegate? = nil,
        startDelay: TimeInterval? = nil
    ) -> some View {
        GuidableView(isActive: isActive, tags: tags, delegate: delegate, startDelay: startDelay) {
            self
        }
    }

    /// Tags this view as a focus target for the walkthrough
    public func sherpaTag<T: SherpaTags>(_ tag: T) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: SherpaTagPreferenceKey.self,
                        value: [tag.key(): SherpaTagInfo(
                            frame: proxy.frame(in: .named("sherpa")),
                            callout: tag.makeCallout()
                        )]
                    )
            }
        }
        .accessibilityElement(children: .contain)
    }
    
    /// Tags the bottom safe area region (e.g., tab bar) for walkthrough highlighting.
    /// Use this for elements that exist in the safe area outside the content bounds.
    /// - Parameters:
    ///   - tag: The tag identifying this step
    ///   - height: Height of the region to highlight (default: 83pt for tab bar + home indicator)
    public func sherpaTabBarTag<T: SherpaTags>(_ tag: T, height: CGFloat = 83) -> some View {
        self.background {
            GeometryReader { proxy in
                // Calculate the frame at the absolute bottom of the screen
                let screenHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
                let tabBarY = screenHeight - height
                let frame = CGRect(x: 0, y: tabBarY, width: proxy.size.width, height: height)
                
                Color.clear
                    .preference(
                        key: SherpaTagPreferenceKey.self,
                        value: [tag.key(): SherpaTagInfo(
                            frame: frame,
                            callout: tag.makeCallout()
                        )]
                    )
            }
        }
    }
    
    // MARK: - Navigation Helpers
    
    /// Stops the walkthrough when a navigation link becomes active
    public func stopSherpa(_ sherpa: Sherpa, onLink navigationLink: Bool) -> some View {
        onChange(of: navigationLink) { _, newValue in
            if newValue {
                sherpa.stop()
            }
        }
    }
    
    /// Stops the walkthrough when navigation selection matches the given tag
    public func stopSherpa<V: Hashable>(_ sherpa: Sherpa, onTag navigationTag: V, selection: V) -> some View {
        onChange(of: selection) { _, newValue in
            if navigationTag == newValue {
                sherpa.stop()
            }
        }
    }
}

// MARK: - Convenience Initializers

extension SherpaContainerView {
    /// Creates a SherpaContainerView with a minimal configuration (no extra UI)
    public static func minimal(@ViewBuilder content: @escaping () -> Content) -> SherpaContainerView {
        SherpaContainerView(configuration: .minimal, content: content)
    }
    
    /// Creates a SherpaContainerView with a bold configuration
    public static func bold(@ViewBuilder content: @escaping () -> Content) -> SherpaContainerView {
        SherpaContainerView(configuration: .bold, content: content)
    }
}
