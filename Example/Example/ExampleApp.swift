//
//  ExampleApp.swift
//  Example
//
//  Demonstrates how to set up Sherpa in your app.
//

import Sherpa
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            // Wrap your entire app in SherpaContainerView
            // You can pass a custom configuration here
            SherpaContainerView(configuration: .default) {
                SherpaDemoList()
            }
        }
    }
}

// MARK: - Alternative Configurations

/*
 // Minimal configuration (no progress indicator, no haptics)
 SherpaContainerView(configuration: .minimal) {
     ContentView()
 }
 
 // Bold configuration (stronger visual emphasis)
 SherpaContainerView(configuration: .bold) {
     ContentView()
 }
 
 // Fully custom configuration
 SherpaContainerView(configuration: SherpaConfiguration(
     spotlightPadding: 16,
     spotlightCornerRadius: 20,
     highlightColor: .blue.opacity(0.6),
     overlayColor: .black.opacity(0.75),
     transitionDuration: 0.4,
     hapticsEnabled: true,
     showProgressIndicator: true,
     progressIndicatorPosition: .bottom
 )) {
     ContentView()
 }
 */
