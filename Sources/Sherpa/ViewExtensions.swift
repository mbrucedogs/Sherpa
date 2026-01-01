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
        anchorPreference(key: SherpaTagPreferenceKey.self, value: .bounds) { anchor in
            [tag.key(): SherpaTagInfo(anchor: anchor, callout: tag.makeCallout())]
        }
        .accessibilityElement(children: .contain)
    }
    
    /// Tags an extended area beyond this view (useful for nav bars, toolbars)
    public func sherpaExtensionTag<T: SherpaTags>(_ tag: T, edge: Edge, size: CGFloat = 100) -> some View {
        let width: CGFloat? = (edge == .leading || edge == .trailing) ? size : nil
        let height: CGFloat? = (edge == .top || edge == .bottom) ? size : nil
        
        let alignment: Alignment = switch edge {
        case .top: .top
        case .leading: .leading
        case .trailing: .trailing
        case .bottom: .bottom
        }
        
        let overlayView = Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(width: width, height: height)
            .sherpaTag(tag)
            .padding(Edge.Set(edge), -size)
        
        return overlay(overlayView, alignment: alignment)
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
