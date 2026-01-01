//
//  NavigationDemo.swift
//  Example
//
//  Demonstrates navigation controls: goBack(), advance(), jump()
//  and the SherpaNavigationButtons component.
//

import Sherpa
import SwiftUI

// MARK: - Tags

enum NavigationTags: SherpaTags {
    case step1
    case step2
    case step3
    case step4
    
    func makeCallout() -> Callout {
        switch self {
        case .step1:
            return .bubble(edge: .bottom) {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text("Step 1: Getting Started")
                        .font(.headline)
                    Text("Use the navigation buttons below to go back and forward.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        case .step2:
            return .bubble(edge: .bottom) {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text("Step 2: Explore Features")
                        .font(.headline)
                    Text("Try pressing the back button!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        case .step3:
            return .bubble(edge: .bottom) {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text("Step 3: Almost Done")
                        .font(.headline)
                    Text("One more step to go.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        case .step4:
            return .bubble(edge: .bottom) {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text("Step 4: Complete!")
                        .font(.headline)
                    Text("Press Done to finish the walkthrough.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Demo View

struct NavigationDemo: View {
    @State private var isActive = false
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xxxxLarge) {
            featureCards
            Spacer()
            startButtonIfNeeded
        }
        .padding(.top, AppDesign.Spacing.xxxxLarge)
        .navigationTitle("Navigation")
        .navigationBarTitleDisplayMode(.inline)
        .sherpa(isActive: isActive, tags: NavigationTags.self, delegate: self)
    }
    
    // MARK: - Subviews
    
    private var featureCards: some View {
        VStack(spacing: AppDesign.Spacing.xxxxLarge) {
            FeatureCard(icon: "1.circle.fill", title: "First Feature", color: .blue)
                .sherpaTag(NavigationTags.step1)
            
            FeatureCard(icon: "2.circle.fill", title: "Second Feature", color: .green)
                .sherpaTag(NavigationTags.step2)
            
            FeatureCard(icon: "3.circle.fill", title: "Third Feature", color: .orange)
                .sherpaTag(NavigationTags.step3)
            
            FeatureCard(icon: "4.circle.fill", title: "Fourth Feature", color: .purple)
                .sherpaTag(NavigationTags.step4)
        }
    }
    
    @ViewBuilder
    private var startButtonIfNeeded: some View {
        if !isActive {
            Button("Start Navigation Demo", action: startDemo)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.App.primary, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
                .padding(.horizontal)
        }
    }
    
    // MARK: - Actions
    
    private func startDemo() {
        isActive = true
    }
}

// MARK: - SherpaDelegate

extension NavigationDemo: SherpaDelegate {
    func accessoryView(sherpa: Sherpa) -> AnyView? {
        AnyView(
            VStack {
                HStack {
                    SkipButton()
                    Spacer()
                }
                
                Spacer()
                
                SherpaNavigationButtons()
                    .padding(.bottom, AppDesign.Size.iconXXLarge)
            }
        )
    }
    
    func onWalkthroughComplete(sherpa: Sherpa) {
        isActive = false
    }
    
    func onWalkthroughSkipped(sherpa: Sherpa, atStep: Int, totalSteps: Int) {
        isActive = false
    }
}

// MARK: - Supporting Views

struct FeatureCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppDesign.Spacing.large) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(color)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        SherpaContainerView {
            NavigationDemo()
        }
    }
}
