//
//  ContainerView.swift
//  Sherpa
//
//  The main container view and overlay components for the Sherpa framework.
//

import SwiftUI

// MARK: - SherpaContainerView

public struct SherpaContainerView<Content: View>: View {
    @State private var sherpa: Sherpa
    @State private var popoverSize: CGSize = .zero
    
    @ViewBuilder let content: () -> Content
    
    public init(configuration: SherpaConfiguration = .default, @ViewBuilder content: @escaping () -> Content) {
        self._sherpa = State(initialValue: Sherpa(configuration: configuration))
        self.content = content
    }
    
    public var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(sherpa)
            .onPreferenceChange(CalloutPreferenceKey.self) { popoverSize = $0 }
            .overlayPreferenceValue(SherpaTagPreferenceKey.self) { all in
                GeometryReader { _ in
                    SherpaOverlay(sherpa: sherpa, allRecordedItems: all, popoverSize: popoverSize)
                        .environment(sherpa)
                }
                .ignoresSafeArea()
            }
    }
}

// MARK: - Skip Button

public struct SkipButton: View {
    @Environment(Sherpa.self) private var sherpa
    
    public init() {}
    
    public var body: some View {
        Button(action: quit) {
            Text(sherpa: SherpaStrings.skip)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, Design.Spacing.large)
                .padding(.vertical, Design.Spacing.small)
                .background(.ultraThinMaterial, in: .capsule)
        }
        .accessibilityLabel(Text(sherpa: SherpaStrings.accessibilitySkipWalkthrough))
        .accessibilityHint(Text(sherpa: SherpaStrings.accessibilitySkipHint))
        .padding(.top, Design.Spacing.safeArea + Design.Spacing.medium)
        .padding(.trailing, Design.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
    
    private func quit() {
        withAnimation(.easeOut(duration: Design.Animation.standard)) {
            sherpa.stop()
        }
    }
}

// MARK: - Progress Indicator

public struct SherpaProgressIndicator: View {
    @Environment(Sherpa.self) private var sherpa
    
    public init() {}
    
    public var body: some View {
        if let currentIndex = sherpa.currentStepIndex {
            HStack(spacing: Design.Spacing.small) {
                ForEach(0..<sherpa.totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.white : Color.white.opacity(Design.Opacity.disabled))
                        .frame(
                            width: index == currentIndex ? Design.Size.progressDotLarge : Design.Size.progressDotSmall,
                            height: index == currentIndex ? Design.Size.progressDotLarge : Design.Size.progressDotSmall
                        )
                        .animation(.easeInOut(duration: Design.Animation.quick), value: currentIndex)
                }
            }
            .padding(.horizontal, Design.Spacing.large)
            .padding(.vertical, Design.Spacing.medium)
            .background(.ultraThinMaterial, in: .capsule)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(SherpaStrings.stepOf(current: currentIndex + 1, total: sherpa.totalSteps))
        }
    }
}

// MARK: - Navigation Buttons

public struct SherpaNavigationButtons: View {
    @Environment(Sherpa.self) private var sherpa
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: Design.Spacing.medium) {
            backButton
            nextButton
        }
    }
    
    private var backButton: some View {
        Button(action: { sherpa.goBack() }) {
            Image(systemName: "chevron.left")
                .font(.body.bold())
                .foregroundStyle(.white)
                .frame(width: Design.Size.buttonMinHeight, height: Design.Size.buttonMinHeight)
                .background(.ultraThinMaterial, in: .circle)
        }
        .opacity(sherpa.isFirstStep ? Design.Opacity.disabled : 1.0)
        .disabled(sherpa.isFirstStep)
        .accessibilityLabel(Text(sherpa: SherpaStrings.accessibilityPreviousStep))
        .accessibilityHint(sherpa.isFirstStep ? Text("Already on first step") : Text("Go to previous step"))
    }
    
    private var nextButton: some View {
        Button(action: { sherpa.advance() }) {
            Group {
                if sherpa.isLastStep {
                    Text(sherpa: SherpaStrings.done)
                        .font(.subheadline.bold())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.body.bold())
                }
            }
            .foregroundStyle(.white)
            .frame(minWidth: Design.Size.buttonMinHeight, minHeight: Design.Size.buttonMinHeight)
            .padding(.horizontal, sherpa.isLastStep ? Design.Spacing.xLarge : 0)
            .background(.ultraThinMaterial, in: sherpa.isLastStep ? AnyShape(.capsule) : AnyShape(.circle))
        }
        .accessibilityLabel(sherpa.isLastStep ? Text(sherpa: SherpaStrings.accessibilityCompleteWalkthrough) : Text(sherpa: SherpaStrings.accessibilityNextStep))
        .accessibilityHint(sherpa.isLastStep ? Text("Finish the walkthrough") : Text("Go to next step"))
    }
}

// MARK: - SherpaOverlay

private struct SherpaOverlay: View {
    let sherpa: Sherpa
    let allRecordedItems: SherpaTagPreferenceKey.Value
    let popoverSize: CGSize
    
    var body: some View {
        ZStack {
            if sherpa.state == .transition {
                transitionOverlay
            } else if sherpa.state == .active {
                activeOverlay
            }
            
            if sherpa.state != .hidden {
                accessoryAndProgressViews
            }
        }
    }
    
    @ViewBuilder
    private var transitionOverlay: some View {
        sherpa.delegate.overlay(sherpa: sherpa)
            .ignoresSafeArea()
        if let current = sherpa.current, let details = allRecordedItems[current] {
            details.callout.createView(onTap: {}).opacity(0)
        }
    }
    
    @ViewBuilder
    private var activeOverlay: some View {
        if let current = sherpa.current, let tagInfo = allRecordedItems[current] {
            ActiveSherpaOverlay(tagInfo: tagInfo, sherpa: sherpa, popoverSize: popoverSize)
        }
    }
    
    @ViewBuilder
    private var accessoryAndProgressViews: some View {
        sherpa.delegate.accessoryView(sherpa: sherpa)
            .environment(sherpa)
        
        if sherpa.configuration.showProgressIndicator {
            progressIndicator
        }
    }
    
    @ViewBuilder
    private var progressIndicator: some View {
        switch sherpa.configuration.progressIndicatorPosition {
        case .top:
            SherpaProgressIndicator()
                .padding(.top, Design.Spacing.safeArea * 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        case .bottom:
            SherpaProgressIndicator()
                .padding(.bottom, Design.Spacing.safeArea * 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

// MARK: - ActiveSherpaOverlay

private struct ActiveSherpaOverlay: View {
    let tagInfo: SherpaTagInfo
    let sherpa: Sherpa
    let popoverSize: CGSize
    
    private var config: SherpaConfiguration { sherpa.configuration }
    
    var body: some View {
        GeometryReader { proxy in
            let cutoutFrame = proxy[tagInfo.anchor]
            let expandedFrame = cutoutFrame.insetBy(dx: -config.spotlightPadding, dy: -config.spotlightPadding)
            let screenSize = proxy.size
            let safeArea = proxy.safeAreaInsets
            
            // Clamp the frame to screen bounds to prevent edge clipping
            let clampedFrame = clampToScreen(frame: expandedFrame, screenSize: screenSize)
            
            spotlightOverlay(expandedFrame: clampedFrame)
            highlightRing(expandedFrame: clampedFrame)
            touchHandler(expandedFrame: clampedFrame)
            calloutView(cutoutFrame: clampedFrame, screenSize: screenSize, safeArea: safeArea)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: config.transitionDuration), value: sherpa.current)
    }
    
    /// Clamps a frame to fit within screen bounds
    private func clampToScreen(frame: CGRect, screenSize: CGSize) -> CGRect {
        let minX = max(0, frame.minX)
        let minY = max(0, frame.minY)
        let maxX = min(screenSize.width, frame.maxX)
        let maxY = min(screenSize.height, frame.maxY)
        
        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
    
    @ViewBuilder
    private func spotlightOverlay(expandedFrame: CGRect) -> some View {
        SpotlightOverlay(
            cutoutFrame: expandedFrame,
            cornerRadius: config.spotlightCornerRadius,
            overlayView: sherpa.delegate.overlay(sherpa: sherpa)
        )
        .contentShape(
            Rectangle().subtracting(
                RoundedRectangle(cornerRadius: config.spotlightCornerRadius)
                    .offset(x: expandedFrame.minX, y: expandedFrame.minY)
                    .size(width: expandedFrame.width, height: expandedFrame.height)
            )
        )
        .onTapGesture {
            sherpa.delegate.onBackgroundTap(sherpa: sherpa)
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Background")
        .accessibilityHint("Tap to continue")
    }
    
    @ViewBuilder
    private func highlightRing(expandedFrame: CGRect) -> some View {
        if config.showHighlightRing {
            RoundedRectangle(cornerRadius: config.spotlightCornerRadius)
                .strokeBorder(config.highlightColor, lineWidth: config.highlightWidth)
                .frame(width: expandedFrame.width, height: expandedFrame.height)
                .position(x: expandedFrame.midX, y: expandedFrame.midY)
                .accessibilityHidden(true)
        }
    }
    
    @ViewBuilder
    private func touchHandler(expandedFrame: CGRect) -> some View {
        switch sherpa.delegate.cutoutTouchMode(sherpa: sherpa) {
        case .passthrough:
            EmptyView()
        case .advance:
            Color.clear
                .contentShape(RoundedRectangle(cornerRadius: config.spotlightCornerRadius))
                .frame(width: expandedFrame.width, height: expandedFrame.height)
                .position(x: expandedFrame.midX, y: expandedFrame.midY)
                .onTapGesture { sherpa.advance() }
                .accessibilityLabel("Highlighted element")
                .accessibilityHint("Tap to continue to next step")
                .accessibilityAddTraits(.isButton)
        case .custom(let action):
            Color.clear
                .contentShape(RoundedRectangle(cornerRadius: config.spotlightCornerRadius))
                .frame(width: expandedFrame.width, height: expandedFrame.height)
                .position(x: expandedFrame.midX, y: expandedFrame.midY)
                .onTapGesture { action() }
                .accessibilityLabel("Highlighted element")
                .accessibilityAddTraits(.isButton)
        }
    }
    
    @ViewBuilder
    private func calloutView(cutoutFrame: CGRect, screenSize: CGSize, safeArea: EdgeInsets) -> some View {
        // Calculate maximum available width accounting for safe areas and padding
        let horizontalPadding = Design.Spacing.small * 2
        let maxCalloutWidth = screenSize.width - safeArea.leading - safeArea.trailing - horizontalPadding
        
        let effectiveSize = popoverSize == .zero 
            ? CGSize(width: min(screenSize.width * 0.6, maxCalloutWidth), height: 50)
            : CGSize(width: min(popoverSize.width, maxCalloutWidth), height: popoverSize.height)
        
        let positioning = calculateCalloutPosition(
            cutout: cutoutFrame,
            preferredEdge: tagInfo.callout.edge,
            popoverSize: effectiveSize,
            screenSize: screenSize,
            safeArea: safeArea
        )
        
        tagInfo.callout.createView(onTap: { sherpa.delegate.onCalloutTap(sherpa: sherpa) })
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: maxCalloutWidth)
            .environment(\.calloutPointerOffset, positioning.pointerOffset)
            .position(x: positioning.point.x + effectiveSize.width / 2, 
                     y: positioning.point.y + effectiveSize.height / 2)
            .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Smart Callout Positioning
    
    private struct CalloutPositioning {
        let point: CGPoint
        let pointerOffset: CGFloat
    }
    
    private func calculateCalloutPosition(
        cutout: CGRect,
        preferredEdge: Edge,
        popoverSize: CGSize,
        screenSize: CGSize,
        safeArea: EdgeInsets
    ) -> CalloutPositioning {
        var x: CGFloat
        var y: CGFloat
        let idealX: CGFloat
        let idealY: CGFloat
        
        let calloutGap = Design.Spacing.small
        
        switch preferredEdge {
        case .top:
            idealX = cutout.midX - popoverSize.width / 2
            x = idealX
            y = cutout.minY - popoverSize.height - calloutGap
            idealY = y
        case .bottom:
            idealX = cutout.midX - popoverSize.width / 2
            x = idealX
            y = cutout.maxY + calloutGap
            idealY = y
        case .leading:
            x = cutout.minX - popoverSize.width - calloutGap
            idealX = x
            idealY = cutout.midY - popoverSize.height / 2
            y = idealY
        case .trailing:
            x = cutout.maxX + calloutGap
            idealX = x
            idealY = cutout.midY - popoverSize.height / 2
            y = idealY
        }
        
        // Use safe area insets for horizontal bounds to prevent clipping at screen edges
        let horizontalPadding = Design.Spacing.small
        let minX = safeArea.leading + horizontalPadding
        let maxX = screenSize.width - popoverSize.width - safeArea.trailing - horizontalPadding
        x = max(minX, min(x, maxX))
        
        let minY = Design.Spacing.safeArea
        let maxY = screenSize.height - popoverSize.height - Design.Spacing.safeArea
        y = max(minY, min(y, maxY))
        
        if preferredEdge == .top && y < Design.Spacing.safeArea {
            y = cutout.maxY
        } else if preferredEdge == .bottom && y + popoverSize.height > screenSize.height - Design.Spacing.safeArea {
            y = cutout.minY - popoverSize.height
        }
        
        let pointerOffset: CGFloat
        switch preferredEdge {
        case .top, .bottom:
            pointerOffset = idealX - x
        case .leading, .trailing:
            pointerOffset = idealY - y
        }
        
        return CalloutPositioning(point: CGPoint(x: x, y: y), pointerOffset: pointerOffset)
    }
}

// MARK: - SpotlightOverlay

private struct SpotlightOverlay<Overlay: View>: View {
    let cutoutFrame: CGRect
    let cornerRadius: CGFloat
    let overlayView: Overlay?
    
    var body: some View {
        if let overlayView {
            overlayView
                .mask {
                    // Use a rectangle that fills all space minus the cutout
                    Rectangle()
                        .fill(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(.black)
                                .frame(width: cutoutFrame.width, height: cutoutFrame.height)
                                .position(x: cutoutFrame.midX, y: cutoutFrame.midY)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                }
        }
    }
}

// MARK: - GuidableView

public struct GuidableView<Content: View, Tags: SherpaTags>: View {
    let isActive: Bool
    let delegate: SherpaDelegate?
    let startDelay: TimeInterval?
    let content: Content

    @Environment(Sherpa.self) private var sherpa: Sherpa?
    
    init(isActive: Bool, tags: Tags.Type, delegate: SherpaDelegate?, startDelay: TimeInterval? = nil, @ViewBuilder content: () -> Content) {
        self.isActive = isActive
        self.delegate = delegate
        self.startDelay = startDelay
        self.content = content()
    }
    
    public var body: some View {
        content
            .onAppear {
                guard let sherpa else { return }
                if isActive {
                    let delay = startDelay ?? sherpa.configuration.startDelay
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))
                        sherpa.start(tags: Tags.self, delegate: delegate)
                    }
                }
            }
            .onDisappear {
                sherpa?.stop()
            }
            .onChange(of: isActive) { _, newValue in
                guard let sherpa else { return }
                if newValue {
                    sherpa.start(tags: Tags.self, delegate: delegate)
                }
            }
    }
}

// MARK: - Preference Keys

struct SherpaTagInfo {
    let anchor: Anchor<CGRect>
    let callout: Callout
}

struct SherpaTagPreferenceKey: PreferenceKey {
    typealias Value = [String: SherpaTagInfo]
    
    static let defaultValue: Value = [:]
    
    static func reduce(value acc: inout Value, nextValue: () -> Value) {
        let newValue = nextValue()
        for (key, value) in newValue {
            acc[key] = value
        }
    }
}
