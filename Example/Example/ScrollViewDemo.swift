//
//  ScrollViewDemo.swift
//  Example
//
//  Demonstrates Sherpa with full-width ScrollViews and edge-to-edge content.
//  Tests callout positioning near screen edges on iPhone and iPad.
//

import Sherpa
import SwiftUI

// MARK: - Tags

enum ChipTags: SherpaTags {
    case chipSelector
    case chip1
    case chip100
    case chip500
    case clearButton
    case dealButton
    
    func makeCallout() -> Callout {
        switch self {
        case .chipSelector:
            return .text("Choose a chip value to bet", edge: .top)
        case .chip1:
            return .text("Start small with $1 chips", edge: .bottom)
        case .chip100:
            return .okText("$100 for bigger bets!")
        case .chip500:
            return .text("High roller! $500 chips", edge: .leading)
        case .clearButton:
            return .text("Clear your current bet", edge: .top)
        case .dealButton:
            return .text("Ready? Deal the cards!", edge: .top)
        }
    }
}

// MARK: - Demo View

struct ScrollViewDemo: View {
    @State private var showWalkthrough = false
    @State private var selectedChip: Int? = 100
    @State private var betAmount: Int = 0
    
    private let chips = [1, 5, 25, 100, 500]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Casino table background
                backgroundGradient
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Player area
                    playerArea
                    
                    Spacer()
                    
                    // Full-width chip selector in ScrollView
                    chipSelectorSection(screenWidth: geometry.size.width)
                    
                    // Action buttons
                    actionButtons
                        .padding(.bottom, AppDesign.Spacing.xxLarge)
                }
            }
        }
        .ignoresSafeArea(edges: .horizontal)
        .navigationTitle("ScrollView Demo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Start Tour") {
                    showWalkthrough = true
                }
                .font(.subheadline.bold())
            }
        }
        .sherpa(isActive: showWalkthrough, tags: ChipTags.self)
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.25, blue: 0.15),
                Color(red: 0.02, green: 0.15, blue: 0.08)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Player Area
    
    private var playerArea: some View {
        VStack(spacing: AppDesign.Spacing.medium) {
            Text("PLAYER")
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            Text("1 : 1")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            
            if betAmount > 0 {
                Text("Bet: $\(betAmount)")
                    .font(.headline)
                    .foregroundStyle(.yellow)
                    .padding(.top, AppDesign.Spacing.small)
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(
            RoundedRectangle(cornerRadius: AppDesign.CornerRadius.medium)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Chip Selector
    
    private func chipSelectorSection(screenWidth: CGFloat) -> some View {
        // This ScrollView is truly edge-to-edge with NO padding on the ScrollView itself
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppDesign.Spacing.medium) {
                ForEach(chips, id: \.self) { value in
                    chipView(value: value)
                        .sherpaTag(tagFor(chip: value))
                }
            }
            .padding(.horizontal, AppDesign.Spacing.xxLarge)
            .frame(minWidth: screenWidth)
        }
        .frame(maxWidth: .infinity) // Ensure it takes full width
        .sherpaTag(ChipTags.chipSelector)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func tagFor(chip value: Int) -> ChipTags {
        switch value {
        case 1: return .chip1
        case 100: return .chip100
        case 500: return .chip500
        default: return .chipSelector
        }
    }
    
    private func chipView(value: Int) -> some View {
        Button {
            selectedChip = value
            betAmount += value
        } label: {
            ZStack {
                Circle()
                    .fill(chipColor(for: value))
                    .frame(width: 60, height: 60)
                
                Circle()
                    .stroke(chipBorderColor(for: value), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .stroke(chipColor(for: value).opacity(0.5), lineWidth: 2)
                    .frame(width: 48, height: 48)
                
                Text("\(value)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .scaleEffect(selectedChip == value ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: selectedChip)
    }
    
    private func chipColor(for value: Int) -> Color {
        switch value {
        case 1: return Color(red: 0.3, green: 0.4, blue: 0.6)
        case 5: return Color(red: 0.7, green: 0.2, blue: 0.2)
        case 25: return Color(red: 0.2, green: 0.6, blue: 0.3)
        case 100: return Color(red: 0.15, green: 0.15, blue: 0.15)
        case 500: return Color(red: 0.4, green: 0.2, blue: 0.5)
        default: return .gray
        }
    }
    
    private func chipBorderColor(for value: Int) -> Color {
        switch value {
        case 100: return .yellow
        default: return chipColor(for: value).opacity(0.3)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: AppDesign.Spacing.large) {
            Button {
                betAmount = 0
            } label: {
                Label("Clear", systemImage: "xmark.circle")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, AppDesign.Spacing.xLarge)
                    .padding(.vertical, AppDesign.Spacing.medium)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .sherpaTag(ChipTags.clearButton)
            
            Button {
                // Deal action
            } label: {
                Label("Deal", systemImage: "play.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppDesign.Spacing.xxLarge)
                    .padding(.vertical, AppDesign.Spacing.medium)
                    .background(
                        Capsule()
                            .fill(betAmount > 0 ? Color.green.opacity(0.8) : Color.gray.opacity(0.5))
                    )
            }
            .disabled(betAmount == 0)
            .sherpaTag(ChipTags.dealButton)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SherpaContainerView {
            ScrollViewDemo()
        }
    }
}
