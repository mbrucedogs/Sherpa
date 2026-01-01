//
//  BasicDemo.swift
//  Example
//
//  A basic profile walkthrough showing common patterns.
//

import Sherpa
import SwiftUI

// MARK: - Define Tags

enum ProfileTags: SherpaTags {
    case profilePicture
    case name
    case stats
    case editButton
    
    func makeCallout() -> Callout {
        switch self {
        case .profilePicture:
            return .text("Your profile picture", edge: .bottom)
        case .name:
            return .okText("This is your display name")
        case .stats:
            return .labeled("View your activity stats", systemImage: "chart.bar.fill")
        case .editButton:
            return .text("Tap to edit your profile", edge: .leading)
        }
    }
}

// MARK: - Demo View

struct BasicDemo: View {
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xxLarge) {
            editButtonSection
            profilePictureSection
            nameSection
            statsSection
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sherpa(isActive: true, tags: ProfileTags.self)
    }
    
    // MARK: - Subviews
    
    private var editButtonSection: some View {
        HStack {
            Spacer()
            Button("Edit", systemImage: "pencil.circle.fill", action: {})
                .font(.title)
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.App.primary)
                .sherpaTag(ProfileTags.editButton)
        }
        .padding(.horizontal)
    }
    
    private var profilePictureSection: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .frame(width: AppDesign.Size.iconLarge, height: AppDesign.Size.iconLarge)
            .foregroundStyle(Color.App.primary.opacity(AppDesign.Opacity.heavy))
            .sherpaTag(ProfileTags.profilePicture)
    }
    
    private var nameSection: some View {
        VStack(spacing: AppDesign.Spacing.xSmall) {
            Text("Jane Doe")
                .font(.title2.bold())
                .sherpaTag(ProfileTags.name)
            
            Text("@janedoe")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: AppDesign.Spacing.xxxLarge) {
            StatView(value: "128", label: "Posts")
            StatView(value: "1.2K", label: "Followers")
            StatView(value: "542", label: "Following")
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: AppDesign.CornerRadius.large))
        .sherpaTag(ProfileTags.stats)
    }
}

// MARK: - Supporting Views

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xSmall) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        SherpaContainerView {
            BasicDemo()
        }
    }
}
