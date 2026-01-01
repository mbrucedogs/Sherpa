//
//  CustomDemo.swift
//  Example
//
//  Demonstrates custom styling: overlay colors, custom callouts, and accessory views.
//

import Sherpa
import SwiftUI

// MARK: - Tags with Custom Callouts

enum CustomTags: SherpaTags {
    case labeledCallout
    case bubbleCallout
    case customCallout
    
    func makeCallout() -> Callout {
        switch self {
        case .labeledCallout:
            return .labeled("This uses the labeled style", systemImage: "star.fill")
            
        case .bubbleCallout:
            return .bubble(edge: .bottom) {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.xSmall) {
                    Text("Custom Bubble Content")
                        .font(.headline)
                    Text("You can put any SwiftUI view here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
        case .customCallout:
            return .custom(edge: .top) { onTap in
                Button(action: onTap) {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                        Text("Fully Custom Design")
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: .rect(cornerRadius: AppDesign.CornerRadius.medium)
                    )
                }
            }
        }
    }
}

// MARK: - Demo View

struct CustomDemo: View {
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xxxLarge) {
            Text("Custom Callout Styles")
                .font(.title2.bold())
                .padding(.top, AppDesign.Spacing.xxxxLarge)
            
            demoItems
            
            Spacer()
            
            noteText
        }
        .navigationTitle("Custom Styling")
        .navigationBarTitleDisplayMode(.inline)
        .sherpa(isActive: true, tags: CustomTags.self, delegate: self)
    }
    
    // MARK: - Subviews
    
    private var demoItems: some View {
        VStack(spacing: AppDesign.Spacing.xxLarge) {
            CustomDemoItem(
                title: "Labeled Style",
                subtitle: ".labeled(\"text\", systemImage: \"icon\")"
            )
            .sherpaTag(CustomTags.labeledCallout)
            
            CustomDemoItem(
                title: "Custom Bubble",
                subtitle: ".bubble { CustomView() }"
            )
            .sherpaTag(CustomTags.bubbleCallout)
            
            CustomDemoItem(
                title: "Fully Custom",
                subtitle: ".custom { onTap in YourView() }"
            )
            .sherpaTag(CustomTags.customCallout)
        }
        .padding(.horizontal)
    }
    
    private var noteText: some View {
        Text("This demo also uses a custom overlay color and accessory view")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

// MARK: - SherpaDelegate

extension CustomDemo: SherpaDelegate {
    func overlay(sherpa: Sherpa) -> AnyView? {
        AnyView(Color.purple.opacity(AppDesign.Opacity.strong))
    }
    
    func accessoryView(sherpa: Sherpa) -> AnyView? {
        AnyView(CustomAccessoryView(sherpa: sherpa))
    }
}

// MARK: - Supporting Views

struct CustomAccessoryView: View {
    let sherpa: Sherpa
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                exitButton
            }
            Spacer()
            stepIndicator
        }
    }
    
    private var exitButton: some View {
        Button("Exit Tour", systemImage: "xmark.circle.fill", action: { sherpa.stop() })
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, AppDesign.Spacing.large)
            .padding(.vertical, AppDesign.Spacing.medium)
            .background(.ultraThinMaterial, in: .capsule)
            .padding()
    }
    
    @ViewBuilder
    private var stepIndicator: some View {
        if let step = sherpa.currentStepIndex {
            Text("Step \(step + 1) of \(sherpa.totalSteps)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, AppDesign.Spacing.large)
                .padding(.vertical, AppDesign.Spacing.small)
                .background(.white.opacity(AppDesign.Opacity.hint), in: .capsule)
                .padding(.bottom, AppDesign.Spacing.safeArea)
        }
    }
}

struct CustomDemoItem: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Private Constants Extension

private extension AppDesign.Spacing {
    static let safeArea: CGFloat = 60
}

#Preview {
    NavigationStack {
        SherpaContainerView {
            CustomDemo()
        }
    }
}
