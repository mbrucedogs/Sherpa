//
//  QuickStartDemo.swift
//  Example
//
//  The simplest possible Sherpa implementation.
//  This is all you need to get started!
//

import Sherpa
import SwiftUI

// MARK: - Step 1: Define your walkthrough steps

enum OnboardingTags: SherpaTags {
    case welcomeButton
    case settingsIcon
    case profilePicture
    
    func makeCallout() -> Callout {
        switch self {
        case .welcomeButton:
            return .text("Tap here to get started!")
        case .settingsIcon:
            return .text("Access your settings here", edge: .bottom)
        case .profilePicture:
            return .okText("This is your profile picture")
        }
    }
}

// MARK: - Step 2: Tag your views and activate

struct QuickStartDemo: View {
    @State private var showWalkthrough = false
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xxxxLarge) {
            headerSection
            
            Spacer()
            
            profileSection
            
            Spacer()
            
            startButton
        }
        .padding()
        .navigationTitle("Quick Start")
        .sherpa(isActive: showWalkthrough, tags: OnboardingTags.self)
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        HStack {
            Spacer()
            Image(systemName: "gearshape.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
                .sherpaTag(OnboardingTags.settingsIcon)
        }
        .padding(.horizontal)
    }
    
    private var profileSection: some View {
        VStack(spacing: AppDesign.Spacing.large) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: AppDesign.Size.iconXXLarge, height: AppDesign.Size.iconXXLarge)
                .foregroundStyle(Color.App.primary)
                .sherpaTag(OnboardingTags.profilePicture)
            
            Text("Welcome to Sherpa!")
                .font(.title2.bold())
            
            Text("A simple walkthrough framework")
                .foregroundStyle(.secondary)
        }
    }
    
    private var startButton: some View {
        Button("Start Walkthrough", action: startWalkthrough)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.App.primary, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
            .sherpaTag(OnboardingTags.welcomeButton)
            .padding(.horizontal, AppDesign.Spacing.xxxxLarge)
    }
    
    // MARK: - Actions
    
    private func startWalkthrough() {
        showWalkthrough = true
    }
}

#Preview {
    NavigationStack {
        SherpaContainerView {
            QuickStartDemo()
        }
    }
}
