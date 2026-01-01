//
//  ContentView.swift
//  Example
//
//  Main navigation for the Sherpa demo app.
//

import SwiftUI
import Sherpa

struct SherpaDemoList: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Getting Started") {
                    NavigationLink(destination: QuickStartDemo()) {
                        Label("Quick Start", systemImage: "play.circle.fill")
                    }
                    
                    NavigationLink(destination: BasicDemo()) {
                        Label("Basic Profile", systemImage: "person.circle")
                    }
                }
                
                Section("Features") {
                    NavigationLink(destination: NavigationDemo()) {
                        Label("Navigation Controls", systemImage: "arrow.left.arrow.right")
                    }
                    
                    NavigationLink(destination: CallbacksDemo()) {
                        Label("Lifecycle Callbacks", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    NavigationLink(destination: ConfigurationDemo()) {
                        Label("Configurations", systemImage: "slider.horizontal.3")
                    }
                }
                
                Section("Advanced") {
                    NavigationLink(destination: BarDemo()) {
                        Label("Bars & Toolbars", systemImage: "menubar.rectangle")
                    }
                    
                    NavigationLink(destination: CustomDemo()) {
                        Label("Custom Styling", systemImage: "paintbrush")
                    }
                    
                    NavigationLink(destination: ManualDemo()) {
                        Label("Manual Flow", systemImage: "arrow.triangle.branch")
                    }
                    
                    NavigationLink(destination: ScrollViewDemo()) {
                        Label("ScrollView & Edges", systemImage: "arrow.left.and.right")
                    }
                }
            }
            .navigationTitle("Sherpa Examples")
        }
    }
}

#Preview {
    SherpaContainerView {
        SherpaDemoList()
    }
}
