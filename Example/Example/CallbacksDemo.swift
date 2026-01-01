//
//  CallbacksDemo.swift
//  Example
//
//  Demonstrates lifecycle callbacks: onStart, onStepChange, onComplete, onSkipped
//

import Sherpa
import SwiftUI

// MARK: - Tags

enum CallbackTags: SherpaTags {
    case feature1
    case feature2
    case feature3
    
    func makeCallout() -> Callout {
        switch self {
        case .feature1:
            return .okText("First feature - check the log below!")
        case .feature2:
            return .okText("Second feature")
        case .feature3:
            return .okText("Last feature - tap to complete")
        }
    }
}

// MARK: - Demo View

struct CallbacksDemo: View {
    @State private var isActive = false
    @State private var logs: [String] = []
    
    // Layout: fixed height for log display
    private let logDisplayHeight: CGFloat = 300
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xLarge) {
            featureIcons
            logDisplay
            Spacer()
            startButton
        }
        .navigationTitle("Callbacks")
        .navigationBarTitleDisplayMode(.inline)
        .sherpa(isActive: isActive, tags: CallbackTags.self, delegate: self)
    }
    
    // MARK: - Subviews
    
    private var featureIcons: some View {
        HStack(spacing: AppDesign.Spacing.xLarge) {
            FeatureIcon(icon: "star.fill", color: .yellow)
                .sherpaTag(CallbackTags.feature1)
            
            FeatureIcon(icon: "heart.fill", color: .red)
                .sherpaTag(CallbackTags.feature2)
            
            FeatureIcon(icon: "bolt.fill", color: .blue)
                .sherpaTag(CallbackTags.feature3)
        }
        .padding(.top, AppDesign.Spacing.xxxxLarge)
    }
    
    private var logDisplay: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
            logHeader
            logContent
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: logDisplayHeight)
        .background(Color.App.logBackground, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
        .padding(.horizontal)
    }
    
    private var logHeader: some View {
        HStack {
            Text("Callback Log")
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Button("Clear", action: clearLogs)
                .font(.caption)
                .foregroundStyle(.white.opacity(AppDesign.Opacity.strong))
        }
    }
    
    private var logContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.xSmall) {
                ForEach(logs.indices, id: \.self) { index in
                    Text(logs[index])
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Color.App.logText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }
    
    private var startButton: some View {
        Button(
            isActive ? "Walkthrough Active..." : "Start Walkthrough",
            action: startWalkthrough
        )
        .font(.headline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(isActive ? Color.gray : Color.App.primary, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
        .disabled(isActive)
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func startWalkthrough() {
        isActive = true
    }
    
    private func clearLogs() {
        logs.removeAll()
    }
    
    private func log(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        logs.append("[\(timestamp)] \(message)")
    }
}

// MARK: - SherpaDelegate

extension CallbacksDemo: SherpaDelegate {
    func onWalkthroughStart(sherpa: Sherpa) {
        log("🚀 onWalkthroughStart()")
    }
    
    func onStepChange(sherpa: Sherpa, stepIndex: Int, totalSteps: Int) {
        log("👣 onStepChange(step: \(stepIndex + 1)/\(totalSteps))")
    }
    
    func onWalkthroughComplete(sherpa: Sherpa) {
        log("✅ onWalkthroughComplete()")
        isActive = false
    }
    
    func onWalkthroughSkipped(sherpa: Sherpa, atStep: Int, totalSteps: Int) {
        log("⏭️ onWalkthroughSkipped(at: \(atStep + 1)/\(totalSteps))")
        isActive = false
    }
}

// MARK: - Supporting Views

struct FeatureIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: AppDesign.Spacing.xxxxLarge))
            .foregroundStyle(color)
            .frame(width: AppDesign.Size.iconMedium, height: AppDesign.Size.iconMedium)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: AppDesign.CornerRadius.large))
            .accessibilityLabel(icon.replacing(".fill", with: ""))
    }
}

#Preview {
    NavigationStack {
        SherpaContainerView {
            CallbacksDemo()
        }
    }
}
