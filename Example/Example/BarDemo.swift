//
//  BarDemo.swift
//  Example
//
//  Demonstrates tagging navigation bars and toolbars using sherpaExtensionTag.
//

import Sherpa
import SwiftUI

// MARK: - Tags

enum BarTags: SherpaTags {
    case navBar
    case content
    case toolbar
    
    func makeCallout() -> Callout {
        switch self {
        case .navBar:
            return .text("This highlights the navigation bar area", edge: .bottom)
        case .content:
            return .okText("Main content area")
        case .toolbar:
            return .text("And this is the toolbar at the bottom")
        }
    }
}

// MARK: - Demo View

struct BarDemo: View {
    // Layout: extension tag sizes
    private let navBarExtensionSize: CGFloat = 100
    private let toolbarExtensionSize: CGFloat = 80
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xxLarge) {
            Spacer()
            mainContent
            Spacer()
            infoSection
        }
        .navigationTitle("Bars Demo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                toolbarContent
            }
        }
        .sherpaExtensionTag(BarTags.navBar, edge: .top, size: navBarExtensionSize)
        .sherpaExtensionTag(BarTags.toolbar, edge: .bottom, size: toolbarExtensionSize)
        .sherpa(isActive: true, tags: BarTags.self)
    }
    
    // MARK: - Subviews
    
    private var mainContent: some View {
        VStack(spacing: AppDesign.Spacing.large) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: AppDesign.Size.iconMedium, height: AppDesign.Size.iconMedium)
                .foregroundStyle(Color.App.primary)
            
            Text("Jane Doe")
                .font(.title2.bold())
            
            Text("@janedoe")
                .foregroundStyle(.secondary)
        }
        .sherpaTag(BarTags.content)
    }
    
    private var infoSection: some View {
        VStack(spacing: AppDesign.Spacing.small) {
            Text("Using sherpaExtensionTag")
                .font(.headline)
            
            Text("Extension tags let you highlight areas outside your view hierarchy, like navigation bars and toolbars.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var toolbarContent: some View {
        HStack {
            Button("Home", systemImage: "house", action: {})
            Spacer()
            Button("Search", systemImage: "magnifyingglass", action: {})
            Spacer()
            Button("Notifications", systemImage: "bell", action: {})
            Spacer()
            Button("Profile", systemImage: "person", action: {})
        }
        .labelStyle(.iconOnly)
    }
}

#Preview {
    NavigationStack {
        SherpaContainerView {
            BarDemo()
        }
    }
}
