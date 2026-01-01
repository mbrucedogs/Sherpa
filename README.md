<div align="center">

# 🏔️ Sherpa

**A modern SwiftUI framework for beautiful onboarding walkthroughs and coach marks**

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![iOS 18+](https://img.shields.io/badge/iOS-18%2B-007AFF?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Native-00D4AA?style=flat-square&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-orange?style=flat-square)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

*Guide your users through your app with elegant, customizable spotlight walkthroughs*

<!-- Add a demo GIF here -->
<!-- ![Sherpa Demo](demo.gif) -->

[Features](#features) • [Installation](#installation) • [Quick Start](#quick-start) • [Examples](#examples) • [API Reference](#api-reference) • [Contributing](#contributing)

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎯 **Spotlight Focus** | Highlights UI elements with a beautiful cutout effect and optional highlight ring |
| 📍 **Smart Positioning** | Callouts automatically reposition to stay within screen bounds |
| 🔙 **Full Navigation** | Go forward, backward, or jump to any step programmatically |
| 🎨 **Highly Customizable** | Configure colors, timing, haptics, corner radii, and more |
| ♿ **Accessible** | Full VoiceOver support with automatic accessibility announcements |
| 📱 **Haptic Feedback** | Subtle haptics on step changes for a polished feel |
| 🌍 **10 Languages** | Built-in translations with easy localization support |
| ⚡ **Modern Swift** | Built with `@Observable`, `@Environment`, and Swift 6 concurrency |

---

## 📦 Installation

### Swift Package Manager

Add Sherpa to your Xcode project:

1. Go to **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/yourusername/Sherpa
   ```
3. Select **Up to Next Major Version** with `1.0.0`

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Sherpa", from: "1.0.0")
]
```

Then add `Sherpa` to your target's dependencies.

---

## 🚀 Quick Start

Get a walkthrough running in **3 simple steps**:

### Step 1: Wrap your app

```swift
import Sherpa
import SwiftUI

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
```

### Step 2: Define your walkthrough steps

```swift
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
```

### Step 3: Tag your views and activate

```swift
struct ContentView: View {
    @State private var showOnboarding = true
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "gear")
                .font(.largeTitle)
                .sherpaTag(OnboardingTags.settingsIcon)
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .sherpaTag(OnboardingTags.profilePicture)
            
            Button("Get Started") { }
                .buttonStyle(.borderedProminent)
                .sherpaTag(OnboardingTags.welcomeButton)
        }
        .sherpa(isActive: showOnboarding, tags: OnboardingTags.self)
    }
}
```

**That's it!** 🎉 Your walkthrough is ready.

---

## 📖 Examples

### Basic Onboarding with Persistence

Show the walkthrough only once using `@AppStorage`:

```swift
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        MyAppContent()
            .sherpa(
                isActive: !hasCompletedOnboarding,
                tags: OnboardingTags.self,
                delegate: self
            )
    }
}

extension ContentView: SherpaDelegate {
    func onWalkthroughComplete(sherpa: Sherpa) {
        hasCompletedOnboarding = true
    }
    
    func onWalkthroughSkipped(sherpa: Sherpa, atStep: Int, totalSteps: Int) {
        hasCompletedOnboarding = true
    }
}
```

### Custom Callout Styles

```swift
enum FeatureTags: SherpaTags {
    case newBadge
    case proTip
    case customDesign
    
    func makeCallout() -> Callout {
        switch self {
        case .newBadge:
            // Simple text with icon
            return .labeled("New feature!", systemImage: "sparkles")
            
        case .proTip:
            // Custom bubble with multiple elements
            return .bubble(edge: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text("Pro Tip")
                            .font(.headline)
                    }
                    Text("Double-tap to quickly access this feature")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
        case .customDesign:
            // Fully custom view
            return .custom(edge: .top) { onTap in
                Button(action: onTap) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                        Text("Tap to continue")
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: .capsule
                    )
                }
            }
        }
    }
}
```

### Manual Navigation Control

Take full control of the walkthrough flow:

```swift
struct ManualFlowDemo: View {
    @Environment(Sherpa.self) private var sherpa: Sherpa?
    
    var body: some View {
        VStack(spacing: 20) {
            // Your tagged content here...
            
            HStack(spacing: 16) {
                Button("Back") {
                    sherpa?.goBack()
                }
                .disabled(sherpa?.isFirstStep ?? true)
                
                Button("Next") {
                    sherpa?.advance()
                }
                
                Button("Skip to End") {
                    sherpa?.jump(to: MyTags.finalStep)
                }
            }
        }
    }
}
```

### Branching Walkthrough

Create non-linear flows where users choose their path:

```swift
enum BranchingTags: SherpaTags {
    case chooseYourPath
    case beginnerPath
    case advancedPath
    case completion
    
    func makeCallout() -> Callout {
        switch self {
        case .chooseYourPath:
            return .bubble(edge: .bottom) {
                VStack {
                    Text("Choose Your Experience")
                        .font(.headline)
                    Text("Select beginner or advanced")
                        .font(.caption)
                }
            }
        case .beginnerPath:
            return .okText("Welcome! Let's start with the basics.")
        case .advancedPath:
            return .okText("Great! Here are the power features.")
        case .completion:
            return .text("You're all set! 🎉")
        }
    }
}

@MainActor
final class BranchingDelegate: SherpaDelegate {
    func cutoutTouchMode(sherpa: Sherpa) -> CutoutTouchMode {
        if sherpa.matchCurrent(BranchingTags.self) == .chooseYourPath {
            return .passthrough  // Allow tapping the buttons underneath
        }
        return .advance
    }
}
```

### Custom Overlay and Accessory Views

Customize the entire walkthrough appearance:

```swift
struct CustomStyledDemo: View, SherpaDelegate {
    var body: some View {
        MyContent()
            .sherpa(isActive: true, tags: MyTags.self, delegate: self)
    }
    
    // Custom purple overlay
    func overlay(sherpa: Sherpa) -> AnyView? {
        AnyView(Color.purple.opacity(0.7))
    }
    
    // Custom accessory view with navigation
    func accessoryView(sherpa: Sherpa) -> AnyView? {
        AnyView(
            VStack {
                // Top: Skip button
                HStack {
                    Spacer()
                    Button("Exit Tour") { sherpa.stop() }
                        .foregroundStyle(.white)
                        .padding()
                }
                
                Spacer()
                
                // Bottom: Navigation and progress
                VStack(spacing: 16) {
                    // Step counter
                    if let step = sherpa.currentStepIndex {
                        Text("Step \(step + 1) of \(sherpa.totalSteps)")
                            .foregroundStyle(.white)
                    }
                    
                    // Navigation buttons
                    SherpaNavigationButtons()
                }
                .padding(.bottom, 60)
            }
        )
    }
}
```

### Highlighting Navigation Bars & Toolbars

Use extension tags for elements outside your view hierarchy:

```swift
struct ToolbarDemo: View {
    var body: some View {
        NavigationStack {
            ContentView()
                .navigationTitle("My App")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Settings", systemImage: "gear") { }
                    }
                }
                // Highlight the entire navigation bar area
                .sherpaExtensionTag(NavTags.navigationBar, edge: .top, size: 100)
                // Highlight a bottom toolbar
                .sherpaExtensionTag(NavTags.toolbar, edge: .bottom, size: 80)
                .sherpa(isActive: true, tags: NavTags.self)
        }
    }
}
```

---

## ⚙️ Configuration

### Preset Configurations

```swift
// Default - balanced appearance with highlight ring
SherpaContainerView(configuration: .default) { ... }

// Minimal - subtle overlay, no highlight ring, no haptics
SherpaContainerView(configuration: .minimal) { ... }

// Bold - darker overlay, thicker highlight, more emphasis
SherpaContainerView(configuration: .bold) { ... }
```

### Custom Configuration

```swift
SherpaContainerView(configuration: SherpaConfiguration(
    spotlightPadding: 12,           // Padding around highlighted element
    spotlightCornerRadius: 16,      // Rounded corners on spotlight
    highlightColor: .blue.opacity(0.5),
    highlightWidth: 3,
    showHighlightRing: true,
    overlayColor: .black.opacity(0.75),
    transitionDuration: 0.4,        // Animation speed
    startDelay: 0.6,                // Delay before walkthrough starts
    hapticsEnabled: true,
    hapticStyle: .medium,           // .light, .medium, .heavy, .soft, .rigid
    showProgressIndicator: true,
    progressIndicatorPosition: .bottom,  // .top or .bottom
    announceStepsForAccessibility: true
)) {
    ContentView()
}
```

### Configuration Reference

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `spotlightPadding` | `CGFloat` | 8 | Padding around the focused element |
| `spotlightCornerRadius` | `CGFloat` | 12 | Corner radius of the spotlight cutout |
| `highlightColor` | `Color` | white 50% | Color of the highlight ring |
| `highlightWidth` | `CGFloat` | 2 | Stroke width of highlight ring |
| `showHighlightRing` | `Bool` | true | Whether to show the highlight ring |
| `overlayColor` | `Color` | black 60% | Color of the dimmed background |
| `transitionDuration` | `TimeInterval` | 0.3 | Animation duration in seconds |
| `startDelay` | `TimeInterval` | 0.5 | Delay before walkthrough begins |
| `stepTransitionDelay` | `TimeInterval` | 0.3 | Delay between step transitions |
| `hapticsEnabled` | `Bool` | true | Enable haptic feedback |
| `hapticStyle` | `UIImpactFeedbackGenerator.FeedbackStyle` | .light | Haptic intensity |
| `showProgressIndicator` | `Bool` | false | Show step indicator dots |
| `progressIndicatorPosition` | `ProgressPosition` | .bottom | Position of progress indicator |
| `announceStepsForAccessibility` | `Bool` | true | Announce steps via VoiceOver |

---

## 📚 API Reference

### SherpaTags Protocol

Define your walkthrough steps by conforming to `SherpaTags`:

```swift
enum MyTags: SherpaTags {
    case step1, step2, step3
    
    func makeCallout() -> Callout {
        // Return the callout for each step
    }
}
```

### View Modifiers

| Modifier | Description |
|----------|-------------|
| `.sherpa(isActive:tags:delegate:startDelay:)` | Activates the walkthrough on this view |
| `.sherpaTag(_:)` | Tags this view as a focus target |
| `.sherpaExtensionTag(_:edge:size:)` | Tags an extended area (for nav bars, toolbars) |
| `.stopSherpa(_:onLink:)` | Stops walkthrough when navigation occurs |

### Callout Factory Methods

| Method | Description |
|--------|-------------|
| `.text(_:edge:)` | Simple text callout |
| `.okText(_:edge:)` | Text with "Ok!" confirmation button |
| `.labeled(_:systemImage:edge:)` | Text with SF Symbol icon |
| `.bubble(edge:content:)` | Custom SwiftUI content in default bubble |
| `.custom(edge:content:)` | Fully custom view |
| `.localizedText(_:edge:bundle:)` | Localized text from string catalog |
| `.localizedOkText(_:edge:bundle:)` | Localized text with Ok button |
| `.localizedLabeled(_:systemImage:edge:bundle:)` | Localized text with icon |

### SherpaDelegate Protocol

```swift
@MainActor
protocol SherpaDelegate {
    // Customize appearance
    func accessoryView(sherpa: Sherpa) -> AnyView?
    func overlay(sherpa: Sherpa) -> AnyView?
    
    // Touch handling
    func cutoutTouchMode(sherpa: Sherpa) -> CutoutTouchMode
    func onBackgroundTap(sherpa: Sherpa)
    func onCalloutTap(sherpa: Sherpa)
    
    // Lifecycle callbacks
    func onWalkthroughStart(sherpa: Sherpa)
    func onStepChange(sherpa: Sherpa, stepIndex: Int, totalSteps: Int)
    func onWalkthroughComplete(sherpa: Sherpa)
    func onWalkthroughSkipped(sherpa: Sherpa, atStep: Int, totalSteps: Int)
}
```

### Sherpa Class Properties & Methods

```swift
// Properties
sherpa.current           // Current step key (String?)
sherpa.state             // .hidden, .transition, or .active
sherpa.currentStepIndex  // Current step index (Int?)
sherpa.totalSteps        // Total number of steps (Int)
sherpa.isActive          // Is walkthrough running? (Bool)
sherpa.isFirstStep       // On first step? (Bool)
sherpa.isLastStep        // On last step? (Bool)
sherpa.configuration     // Current configuration

// Methods
sherpa.start(tags:delegate:)  // Start walkthrough programmatically
sherpa.advance()              // Go to next step
sherpa.goBack()               // Go to previous step
sherpa.jump(to:)              // Jump to specific tag
sherpa.stop(animated:)        // Stop the walkthrough
sherpa.matchCurrent(_:)       // Get current tag as specific type
```

---

## 🌍 Localization

Sherpa includes built-in translations for:

| Language | Code |
|----------|------|
| 🇺🇸 English | en |
| 🇪🇸 Spanish | es |
| 🇫🇷 French | fr |
| 🇩🇪 German | de |
| 🇯🇵 Japanese | ja |
| 🇨🇳 Chinese (Simplified) | zh-Hans |
| 🇧🇷 Portuguese (Brazil) | pt-BR |
| 🇮🇹 Italian | it |
| 🇰🇷 Korean | ko |
| 🇸🇦 Arabic | ar |

UI elements (Skip, Done, Ok!, accessibility labels) are automatically translated.

### Localizing Your Content

Use your app's string catalog for callout text:

```swift
// In your Localizable.xcstrings:
// "onboarding.welcome" = "Welcome to our app!"

func makeCallout() -> Callout {
    .localizedText("onboarding.welcome")
}
```

---

## 💡 Best Practices

1. **Keep it short** — 3-5 steps maximum for onboarding
2. **Focus on value** — Highlight features that benefit users most
3. **Always allow skipping** — Respect users who want to explore
4. **Show only once** — Use `@AppStorage` to track completion
5. **Test on device** — Haptics and animations feel different on hardware
6. **Consider timing** — Don't start immediately; let the UI settle first
7. **Use clear language** — Keep callout text concise and actionable

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Report bugs** — Open an issue with reproduction steps
2. **Suggest features** — Open an issue describing your idea
3. **Add translations** — Edit `Sources/Sherpa/Resources/Localizable.xcstrings`
4. **Submit PRs** — Fork, create a branch, and submit a pull request

---

## 📋 Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 18.0+ |
| Swift | 6.0+ |
| Xcode | 16.0+ |

---

## 📄 License

Sherpa is available under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ for the SwiftUI community**

⭐ Star this repo if you find it helpful!

</div>
