//
//  Sherpa.swift
//  Sherpa
//
//  A SwiftUI walkthrough and onboarding framework.
//

import SwiftUI

// MARK: - SherpaDelegate Protocol

@MainActor
public protocol SherpaDelegate {
    /// Returns a custom accessory view (e.g., skip button). Return nil to hide.
    func accessoryView(sherpa: Sherpa) -> AnyView?
    
    /// Returns the overlay view that dims the background.
    func overlay(sherpa: Sherpa) -> AnyView?
    
    /// Determines how touches on the spotlight cutout are handled.
    func cutoutTouchMode(sherpa: Sherpa) -> CutoutTouchMode
    
    /// Called when the user taps the dimmed background area.
    func onBackgroundTap(sherpa: Sherpa)
    
    /// Called when the user taps the callout tooltip.
    func onCalloutTap(sherpa: Sherpa)
    
    // MARK: - Lifecycle Callbacks
    
    /// Called when the walkthrough starts.
    func onWalkthroughStart(sherpa: Sherpa)
    
    /// Called when moving to a new step. Provides current step index (0-based) and total steps.
    func onStepChange(sherpa: Sherpa, stepIndex: Int, totalSteps: Int)
    
    /// Called when the walkthrough completes (user went through all steps).
    func onWalkthroughComplete(sherpa: Sherpa)
    
    /// Called when the walkthrough is skipped/stopped early.
    func onWalkthroughSkipped(sherpa: Sherpa, atStep: Int, totalSteps: Int)
}

// MARK: - Default Implementations

extension SherpaDelegate {
    public func accessoryView(sherpa: Sherpa) -> AnyView? {
        AnyView(SkipButton())
    }
    
    public func overlay(sherpa: Sherpa) -> AnyView? {
        AnyView(sherpa.configuration.overlayColor)
    }
    
    public func cutoutTouchMode(sherpa: Sherpa) -> CutoutTouchMode {
        .advance
    }
    
    public func onBackgroundTap(sherpa: Sherpa) {
        sherpa.advance()
    }
    
    public func onCalloutTap(sherpa: Sherpa) {
        sherpa.advance()
    }
    
    public func onWalkthroughStart(sherpa: Sherpa) {}
    public func onStepChange(sherpa: Sherpa, stepIndex: Int, totalSteps: Int) {}
    public func onWalkthroughComplete(sherpa: Sherpa) {}
    public func onWalkthroughSkipped(sherpa: Sherpa, atStep: Int, totalSteps: Int) {}
}

@MainActor
struct DefaultSherpaDelegate: SherpaDelegate {}

// MARK: - Sherpa Main Class

@MainActor
@Observable
public final class Sherpa {
    
    // MARK: - Public Properties
    
    /// The key of the currently focused tag
    public private(set) var current: String? = nil
    
    /// Current state of the walkthrough
    public internal(set) var state: SherpaState = .hidden
    
    /// Current step index (0-based). Returns nil if walkthrough is not active.
    public var currentStepIndex: Int? {
        guard let current = current, let plan = currentPlan else { return nil }
        return plan.firstIndex(of: current)
    }
    
    /// Total number of steps in the current walkthrough. Returns 0 if not active.
    public var totalSteps: Int {
        currentPlan?.count ?? 0
    }
    
    /// Whether the walkthrough is currently active
    public var isActive: Bool {
        state != .hidden
    }
    
    /// Whether we're on the first step
    public var isFirstStep: Bool {
        currentStepIndex == 0
    }
    
    /// Whether we're on the last step
    public var isLastStep: Bool {
        guard let index = currentStepIndex else { return false }
        return index == totalSteps - 1
    }
    
    /// Configuration for appearance and behavior
    public var configuration: SherpaConfiguration = .default
    
    // MARK: - Internal Properties
    
    private var currentPlan: [String]?
    var delegate: SherpaDelegate = DefaultSherpaDelegate()
    private var hapticGenerator: UIImpactFeedbackGenerator?
    
    // MARK: - Initialization
    
    public init(configuration: SherpaConfiguration = .default) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    
    /// Starts the walkthrough with the given tags
    public func start<Tags: SherpaTags>(tags: Tags.Type, delegate: SherpaDelegate? = nil) {
        let plan = tags.allCases.map { $0.key() }
        currentPlan = plan
        self.delegate = delegate ?? DefaultSherpaDelegate()
        
        // Prepare haptic generator
        if configuration.hapticsEnabled {
            hapticGenerator = UIImpactFeedbackGenerator(style: configuration.hapticStyle)
            hapticGenerator?.prepare()
        }
        
        guard !plan.isEmpty else { return }
        
        // Notify delegate
        self.delegate.onWalkthroughStart(sherpa: self)
        
        moveTo(item: plan[0], isInitial: true)
    }
    
    /// Advances to the next step. If on the last step, completes the walkthrough.
    public func advance() {
        guard let current = current, let currentPlan = currentPlan else { return }
        guard let index = currentPlan.firstIndex(of: current) else { return }
        
        guard index + 1 < currentPlan.count else {
            complete()
            return
        }
        
        moveTo(item: currentPlan[index + 1])
    }
    
    /// Goes back to the previous step. Does nothing if on the first step.
    public func goBack() {
        guard let current = current, let currentPlan = currentPlan else { return }
        guard let index = currentPlan.firstIndex(of: current), index > 0 else { return }
        
        moveTo(item: currentPlan[index - 1])
    }
    
    /// Jumps directly to a specific tag
    public func jump<T: SherpaTags>(to tag: T) {
        guard let currentPlan = currentPlan, let index = currentPlan.firstIndex(of: tag.key()) else {
            return
        }
        moveTo(item: currentPlan[index])
    }
    
    /// Returns the current tag as the specified type
    public func matchCurrent<T: SherpaTags>(_ tags: T.Type) -> T? {
        T.allCases.first(where: { $0.key() == current })
    }
    
    /// Stops the walkthrough. Calls onWalkthroughSkipped if not on last step.
    public func stop(animated: Bool = true) {
        let wasActive = isActive
        let stepIndex = currentStepIndex ?? 0
        let total = totalSteps
        
        if animated {
            withAnimation(.easeOut(duration: Design.Animation.standard)) {
                stopImpl()
            }
        } else {
            stopImpl()
        }
        
        // Notify delegate if skipped (not completed naturally)
        if wasActive && stepIndex < total - 1 {
            delegate.onWalkthroughSkipped(sherpa: self, atStep: stepIndex, totalSteps: total)
        }
    }
    
    // MARK: - Private Methods
    
    private func complete() {
        delegate.onWalkthroughComplete(sherpa: self)
        playHaptic()
        
        withAnimation(.easeOut(duration: Design.Animation.standard)) {
            stopImpl()
        }
    }
    
    private func moveTo(item: String, isInitial: Bool = false) {
        withAnimation(.easeInOut(duration: configuration.transitionDuration)) {
            if state == .active {
                state = .transition
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(Int(configuration.stepTransitionDelay * 1000)))
                    self.current = item
                    self.state = .transition
                    
                    // Notify delegate
                    if let index = self.currentStepIndex {
                        self.delegate.onStepChange(sherpa: self, stepIndex: index, totalSteps: self.totalSteps)
                        self.playHaptic()
                        self.announceForAccessibility()
                    }
                    
                    withAnimation(.easeInOut(duration: self.configuration.transitionDuration)) {
                        self.state = .active
                    }
                }
            } else {
                current = item
                state = .active
                
                // Notify delegate for initial step
                if isInitial, let index = currentStepIndex {
                    delegate.onStepChange(sherpa: self, stepIndex: index, totalSteps: totalSteps)
                    playHaptic()
                    announceForAccessibility()
                }
            }
        }
    }
    
    private func stopImpl() {
        state = .hidden
        currentPlan = nil
        current = nil
        hapticGenerator = nil
    }
    
    private func playHaptic() {
        guard configuration.hapticsEnabled else { return }
        hapticGenerator?.impactOccurred()
    }
    
    private func announceForAccessibility() {
        guard configuration.announceStepsForAccessibility else { return }
        guard let index = currentStepIndex else { return }
        
        let announcement = SherpaStrings.stepOf(current: index + 1, total: totalSteps)
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
}

// MARK: - Supporting Types

public enum SherpaState: Sendable {
    case hidden
    case transition
    case active
}

public enum CutoutTouchMode: Sendable {
    case passthrough
    case advance
    case custom(@Sendable @MainActor () -> Void)
}

// MARK: - SherpaTags Protocol

@MainActor
public protocol SherpaTags: CaseIterable {
    func makeCallout() -> Callout
}

extension SherpaTags {
    func key() -> String {
        String(reflecting: Self.self) + "." + String(describing: self)
    }
}
