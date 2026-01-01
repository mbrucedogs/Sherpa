# Sherpa - AI Implementation Guide

This document is optimized for AI assistants implementing Sherpa walkthroughs.

## Overview

Sherpa is a SwiftUI walkthrough/onboarding framework. It highlights UI elements with a spotlight effect and shows callout tooltips.

**Requirements:** iOS 18+, Swift 6+, SwiftUI

## Core Concepts

1. `SherpaContainerView` - Wraps app content, provides the overlay
2. `SherpaTags` - Protocol for defining walkthrough steps (enum)
3. `Callout` - The tooltip shown for each step
4. `.sherpaTag()` - Modifier to mark a view as focusable
5. `.sherpa()` - Modifier to activate the walkthrough

## Minimal Implementation

```swift
import Sherpa
import SwiftUI

// 1. Define steps as an enum conforming to SherpaTags
enum MyTags: SherpaTags {
    case step1
    case step2
    case step3
    
    func makeCallout() -> Callout {
        switch self {
        case .step1: return .text("First step explanation")
        case .step2: return .text("Second step", edge: .bottom)
        case .step3: return .okText("Final step - tap Ok!")
        }
    }
}

// 2. Wrap app in SherpaContainerView (typically in @main App)
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            SherpaContainerView {
                ContentView()
            }
        }
    }
}

// 3. Tag views and activate walkthrough
struct ContentView: View {
    @State private var showWalkthrough = true
    
    var body: some View {
        VStack {
            Text("Welcome")
                .sherpaTag(MyTags.step1)
            
            Button("Action") { }
                .sherpaTag(MyTags.step2)
            
            Image(systemName: "star")
                .sherpaTag(MyTags.step3)
        }
        .sherpa(isActive: showWalkthrough, tags: MyTags.self)
    }
}
```

## All Callout Types

```swift
// Simple text (default edge: .top)
.text("Message")
.text("Message", edge: .bottom)  // .top, .bottom, .leading, .trailing

// Text with "Ok!" button
.okText("Message")
.okText("Message", edge: .leading)

// Text with SF Symbol icon
.labeled("Message", systemImage: "star.fill")
.labeled("Message", systemImage: "star.fill", edge: .bottom)

// Custom content in default bubble style
.bubble(edge: .bottom) {
    VStack {
        Text("Title").font(.headline)
        Text("Subtitle").font(.caption)
    }
}

// Fully custom view (you handle all styling)
.custom(edge: .top) { onTap in
    Button(action: onTap) {
        Text("Custom Button")
            .padding()
            .background(Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(8)
    }
}

// Localized versions (uses app's Localizable.xcstrings)
.localizedText("key.name")
.localizedOkText("key.name", edge: .bottom)
.localizedLabeled("key.name", systemImage: "star")
```

## View Modifiers

```swift
// Tag a view for highlighting
view.sherpaTag(MyTags.step1)

// Activate walkthrough on a view hierarchy
view.sherpa(isActive: Bool, tags: MyTags.self)
view.sherpa(isActive: Bool, tags: MyTags.self, delegate: myDelegate)
view.sherpa(isActive: Bool, tags: MyTags.self, delegate: myDelegate, startDelay: 0.5)

// Tag areas outside view hierarchy (nav bars, toolbars)
view.sherpaExtensionTag(MyTags.navBar, edge: .top, size: 100)
view.sherpaExtensionTag(MyTags.tabBar, edge: .bottom, size: 80)
```

## Configuration Options

```swift
// Preset configurations
SherpaContainerView(configuration: .default) { }  // Standard
SherpaContainerView(configuration: .minimal) { }  // Subtle, no haptics
SherpaContainerView(configuration: .bold) { }     // Strong emphasis

// Custom configuration
SherpaContainerView(configuration: SherpaConfiguration(
    spotlightPadding: 8,              // CGFloat - padding around element
    spotlightCornerRadius: 12,        // CGFloat - corner radius
    highlightColor: .white.opacity(0.5),  // Color - ring color
    highlightWidth: 2,                // CGFloat - ring stroke width
    showHighlightRing: true,          // Bool
    overlayColor: .black.opacity(0.6),    // Color - dim background
    transitionDuration: 0.3,          // TimeInterval - animation speed
    startDelay: 0.5,                  // TimeInterval - delay before start
    stepTransitionDelay: 0.3,         // TimeInterval - delay between steps
    hapticsEnabled: true,             // Bool
    hapticStyle: .light,              // UIImpactFeedbackGenerator.FeedbackStyle
    showProgressIndicator: false,     // Bool - show step dots
    progressIndicatorPosition: .bottom,   // .top or .bottom
    announceStepsForAccessibility: true   // Bool - VoiceOver announcements
)) { }
```

## SherpaDelegate Protocol

Implement to customize behavior and receive callbacks:

```swift
@MainActor
protocol SherpaDelegate {
    // Return custom skip button or nil to hide
    func accessoryView(sherpa: Sherpa) -> AnyView?
    
    // Return custom overlay color/view
    func overlay(sherpa: Sherpa) -> AnyView?
    
    // How to handle taps on the highlighted element
    func cutoutTouchMode(sherpa: Sherpa) -> CutoutTouchMode
    // CutoutTouchMode options:
    //   .advance - tap advances to next step (default)
    //   .passthrough - tap goes through to the element
    //   .custom { /* action */ } - custom handler
    
    // Called when user taps the dimmed background
    func onBackgroundTap(sherpa: Sherpa)
    
    // Called when user taps the callout
    func onCalloutTap(sherpa: Sherpa)
    
    // Lifecycle callbacks
    func onWalkthroughStart(sherpa: Sherpa)
    func onStepChange(sherpa: Sherpa, stepIndex: Int, totalSteps: Int)
    func onWalkthroughComplete(sherpa: Sherpa)
    func onWalkthroughSkipped(sherpa: Sherpa, atStep: Int, totalSteps: Int)
}

// All methods have default implementations - only override what you need
```

## Delegate Implementation Example

```swift
struct MyView: View, SherpaDelegate {
    @State private var isActive = false
    
    var body: some View {
        Content()
            .sherpa(isActive: isActive, tags: MyTags.self, delegate: self)
    }
    
    // Custom purple overlay
    func overlay(sherpa: Sherpa) -> AnyView? {
        AnyView(Color.purple.opacity(0.7))
    }
    
    // Allow taps to pass through on specific step
    func cutoutTouchMode(sherpa: Sherpa) -> CutoutTouchMode {
        if sherpa.matchCurrent(MyTags.self) == .buttonStep {
            return .passthrough
        }
        return .advance
    }
    
    func onWalkthroughComplete(sherpa: Sherpa) {
        isActive = false
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}
```

## Programmatic Control

Access Sherpa via environment:

```swift
struct MyView: View {
    @Environment(Sherpa.self) private var sherpa: Sherpa?
    
    var body: some View {
        VStack {
            Button("Next") { sherpa?.advance() }
            Button("Back") { sherpa?.goBack() }
            Button("Jump") { sherpa?.jump(to: MyTags.step3) }
            Button("Stop") { sherpa?.stop() }
        }
    }
}

// Sherpa properties
sherpa.isActive          // Bool - is walkthrough running
sherpa.isFirstStep       // Bool
sherpa.isLastStep        // Bool
sherpa.currentStepIndex  // Int? - 0-based index
sherpa.totalSteps        // Int
sherpa.current           // String? - current step key
sherpa.state             // SherpaState: .hidden, .transition, .active

// Match current step to your enum
if sherpa.matchCurrent(MyTags.self) == .step2 {
    // Currently on step2
}
```

## Starting Programmatically

```swift
struct MyView: View {
    @Environment(Sherpa.self) private var sherpa: Sherpa?
    
    func startTour() {
        sherpa?.start(tags: MyTags.self, delegate: myDelegate)
    }
}
```

## Built-in UI Components

```swift
// Skip button (shows in top-right by default)
SkipButton()

// Progress dots showing current step
SherpaProgressIndicator()

// Back/Next navigation buttons
SherpaNavigationButtons()

// Use in delegate's accessoryView:
func accessoryView(sherpa: Sherpa) -> AnyView? {
    AnyView(
        VStack {
            HStack { SkipButton(); Spacer() }
            Spacer()
            SherpaProgressIndicator()
            SherpaNavigationButtons()
                .padding(.bottom, 60)
        }
    )
}
```

## Common Patterns

### Show walkthrough only once

```swift
struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        MyContent()
            .sherpa(isActive: !hasSeenOnboarding, tags: OnboardingTags.self, delegate: self)
    }
}

extension ContentView: SherpaDelegate {
    func onWalkthroughComplete(sherpa: Sherpa) {
        hasSeenOnboarding = true
    }
    
    func onWalkthroughSkipped(sherpa: Sherpa, atStep: Int, totalSteps: Int) {
        hasSeenOnboarding = true
    }
}
```

### Branching/non-linear flow

```swift
// In your delegate:
func cutoutTouchMode(sherpa: Sherpa) -> CutoutTouchMode {
    if sherpa.matchCurrent(MyTags.self) == .choiceStep {
        return .passthrough  // Let user tap underlying buttons
    }
    return .advance
}

// In your view, buttons call jump():
Button("Option A") { sherpa?.jump(to: MyTags.optionAStep) }
Button("Option B") { sherpa?.jump(to: MyTags.optionBStep) }
```

### Highlighting nav bar or toolbar

```swift
MyView()
    .navigationTitle("Title")
    .toolbar { /* toolbar items */ }
    .sherpaExtensionTag(MyTags.navBar, edge: .top, size: 100)
    .sherpaExtensionTag(MyTags.toolbar, edge: .bottom, size: 80)
    .sherpa(isActive: true, tags: MyTags.self)
```

## Edge Cases

1. **Environment access:** Use `@Environment(Sherpa.self) private var sherpa: Sherpa?` (optional) when accessing in child views
2. **NavigationStack:** The `.sherpa()` modifier should be inside the NavigationStack, not outside
3. **Sheets/modals:** Each sheet needs its own `SherpaContainerView` if you want walkthroughs inside
4. **Tab views:** Place `SherpaContainerView` inside each tab's content, not around TabView

## File Structure

```
Sources/Sherpa/
├── Sherpa.swift           # Main class, delegate protocol, tags protocol
├── SherpaConfiguration.swift  # Configuration struct
├── ContainerView.swift    # SherpaContainerView, overlay, UI components
├── ViewExtensions.swift   # View modifiers (.sherpa, .sherpaTag, etc.)
├── Callout.swift          # Callout struct and factory methods
├── Design.swift           # Design constants and colors
├── Localization.swift     # Localized strings
└── Resources/
    └── Localizable.xcstrings  # Translations (10 languages)
```
