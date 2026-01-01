//
//  ManualDemo.swift
//  Example
//
//  Demonstrates manual flow control: starting programmatically,
//  jumping between steps, and using goBack().
//

import Sherpa
import SwiftUI

// MARK: - Tags

enum ManualTags: SherpaTags {
    case startButton
    case choiceButtons
    case leftPath
    case rightPath
    case endPoint
    
    func makeCallout() -> Callout {
        switch self {
        case .startButton:
            return .text("Press Start to begin manually", edge: .top)
        case .choiceButtons:
            return .bubble(edge: .bottom) {
                VStack(spacing: AppDesign.Spacing.xSmall) {
                    Text("Choose a path!")
                        .font(.headline)
                    Text("Tap Left or Right to jump to that step")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        case .leftPath:
            return .okText("You chose the left path!", edge: .trailing)
        case .rightPath:
            return .okText("You chose the right path!", edge: .leading)
        case .endPoint:
            return .bubble(edge: .top) {
                VStack(spacing: AppDesign.Spacing.xSmall) {
                    Text("Both paths lead here!")
                        .font(.headline)
                    Text("Tap to complete the walkthrough")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Demo View

struct ManualDemo: View {
    var body: some View {
        ManualDemoContent()
            .navigationTitle("Manual Flow")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Content View (accesses Environment)

private struct ManualDemoContent: View {
    @Environment(Sherpa.self) private var sherpa: Sherpa?
    @State private var hasStarted = false
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xxxLarge) {
            startButton
            choiceButtons
            pathDestinations
            endPoint
            Spacer()
            instructionsSection
        }
    }
    
    // MARK: - Subviews
    
    private var startButton: some View {
        Button("Start Walkthrough", systemImage: "play.fill", action: startWalkthrough)
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.App.primary, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
            .sherpaTag(ManualTags.startButton)
            .padding(.horizontal)
            .padding(.top, AppDesign.Spacing.xLarge)
    }
    
    private var choiceButtons: some View {
        HStack(spacing: AppDesign.Spacing.xLarge) {
            Button(action: { sherpa?.jump(to: ManualTags.leftPath) }) {
                VStack {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.largeTitle)
                    Text("Go Left")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.App.warning.opacity(AppDesign.Opacity.hint), in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
            }
            .foregroundStyle(Color.App.warning)
            
            Button(action: { sherpa?.jump(to: ManualTags.rightPath) }) {
                VStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.largeTitle)
                    Text("Go Right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.App.success.opacity(AppDesign.Opacity.hint), in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
            }
            .foregroundStyle(Color.App.success)
        }
        .sherpaTag(ManualTags.choiceButtons)
        .padding(.horizontal)
    }
    
    private var pathDestinations: some View {
        HStack(spacing: AppDesign.Spacing.xLarge) {
            PathDestination(title: "Left", color: Color.App.warning)
                .sherpaTag(ManualTags.leftPath)
            
            PathDestination(title: "Right", color: Color.App.success)
                .sherpaTag(ManualTags.rightPath)
        }
        .padding(.horizontal)
    }
    
    private var endPoint: some View {
        VStack(spacing: AppDesign.Spacing.small) {
            Image(systemName: "flag.checkered")
                .font(.system(size: AppDesign.Spacing.xxxxLarge))
            Text("Finish Line")
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.App.purple.opacity(AppDesign.Opacity.hint), in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
        .sherpaTag(ManualTags.endPoint)
        .padding(.horizontal)
    }
    
    private var instructionsSection: some View {
        VStack(spacing: AppDesign.Spacing.small) {
            Text("Manual Flow Control")
                .font(.headline)
            Text("This demo shows how to:\n• Start walkthrough programmatically\n• Jump to specific steps with sherpa.jump(to:)\n• Use custom touch handling")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func startWalkthrough() {
        guard let sherpa else { return }
        hasStarted = true
        sherpa.start(tags: ManualTags.self, delegate: ManualDemoDelegate(sherpa: sherpa))
    }
}

// MARK: - Delegate

@MainActor
final class ManualDemoDelegate: SherpaDelegate {
    private let sherpa: Sherpa
    
    init(sherpa: Sherpa) {
        self.sherpa = sherpa
    }
    
    func cutoutTouchMode(sherpa: Sherpa) -> CutoutTouchMode {
        switch sherpa.matchCurrent(ManualTags.self) {
        case .choiceButtons:
            return .passthrough
        case .leftPath, .rightPath:
            return .custom { [weak self] in
                self?.sherpa.jump(to: ManualTags.endPoint)
            }
        default:
            return .advance
        }
    }
    
    func onBackgroundTap(sherpa: Sherpa) {
        handleTap()
    }
    
    func onCalloutTap(sherpa: Sherpa) {
        handleTap()
    }
    
    private func handleTap() {
        switch sherpa.matchCurrent(ManualTags.self) {
        case .leftPath, .rightPath:
            sherpa.jump(to: ManualTags.endPoint)
        default:
            sherpa.advance()
        }
    }
}

// MARK: - Supporting Views

struct PathDestination: View {
    let title: String
    let color: Color
    
    // Typography: fixed size for badge
    private let badgeFontSize: CGFloat = 24
    
    var body: some View {
        VStack {
            Circle()
                .fill(color)
                .frame(width: AppDesign.Size.iconMedium, height: AppDesign.Size.iconMedium)
                .overlay {
                    Text(title.prefix(1))
                        .font(.system(size: badgeFontSize, weight: .bold))
                        .foregroundStyle(.white)
                }
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(AppDesign.Opacity.subtle), in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) path destination")
    }
}

#Preview {
    NavigationStack {
        SherpaContainerView {
            ManualDemo()
        }
    }
}
