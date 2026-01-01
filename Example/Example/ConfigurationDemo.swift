//
//  ConfigurationDemo.swift
//  Example
//
//  Demonstrates different SherpaConfiguration presets and custom options.
//

import Sherpa
import SwiftUI

// MARK: - Tags

enum ConfigTags: SherpaTags {
    case item1
    case item2
    case item3
    
    func makeCallout() -> Callout {
        switch self {
        case .item1:
            return .text("First item")
        case .item2:
            return .text("Second item")
        case .item3:
            return .text("Third item")
        }
    }
}

// MARK: - Demo View

struct ConfigurationDemo: View {
    @State private var selectedConfig: ConfigOption = .default
    @State private var showPreview = false
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.xxLarge) {
            configPicker
            configDescription
            Divider()
            featureList
            Spacer()
            codePreview
            previewButton
        }
        .padding(.top)
        .navigationTitle("Configurations")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPreview) {
            ConfigPreviewSheet(config: selectedConfig)
        }
    }
    
    // MARK: - Subviews
    
    private var configPicker: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
            Text("Select Configuration")
                .font(.headline)
            
            Picker("Configuration", selection: $selectedConfig) {
                ForEach(ConfigOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
    
    private var configDescription: some View {
        Text(selectedConfig.description)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var featureList: some View {
        VStack(spacing: AppDesign.Spacing.large) {
            ConfigItem(title: "Feature One", icon: "1.circle.fill")
            ConfigItem(title: "Feature Two", icon: "2.circle.fill")
            ConfigItem(title: "Feature Three", icon: "3.circle.fill")
        }
        .padding()
    }
    
    private var codePreview: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
            Text("Code")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedConfig.codeExample)
                .font(.system(.caption2, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(AppDesign.Opacity.subtle), in: .rect(cornerRadius: AppDesign.CornerRadius.small))
        }
        .padding(.horizontal)
    }
    
    private var previewButton: some View {
        Button("Preview This Configuration", action: previewConfiguration)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.App.primary, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
            .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func previewConfiguration() {
        showPreview = true
    }
}

// MARK: - Preview Sheet

struct ConfigPreviewSheet: View {
    let config: ConfigOption
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    
    var body: some View {
        NavigationStack {
            SherpaContainerView(configuration: config.configuration) {
                VStack(spacing: AppDesign.Spacing.xxLarge) {
                    Text("Preview: \(config.rawValue)")
                        .font(.title2.bold())
                        .padding(.top, AppDesign.Spacing.xxxLarge)
                    
                    Text(config.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    VStack(spacing: AppDesign.Spacing.large) {
                        ConfigItem(title: "Feature One", icon: "1.circle.fill")
                            .sherpaTag(ConfigTags.item1)
                        
                        ConfigItem(title: "Feature Two", icon: "2.circle.fill")
                            .sherpaTag(ConfigTags.item2)
                        
                        ConfigItem(title: "Feature Three", icon: "3.circle.fill")
                            .sherpaTag(ConfigTags.item3)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Start Walkthrough") {
                        isActive = true
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.App.primary, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .sherpa(isActive: isActive, tags: ConfigTags.self)
            }
            .navigationTitle("\(config.rawValue) Config")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}


// MARK: - Configuration Options

enum ConfigOption: String, CaseIterable {
    case `default` = "Default"
    case minimal = "Minimal"
    case bold = "Bold"
    
    var description: String {
        switch self {
        case .default:
            return "Standard configuration with all features enabled"
        case .minimal:
            return "No progress indicator, no haptics, no highlight ring"
        case .bold:
            return "Stronger visual emphasis with larger spotlight"
        }
    }
    
    var configuration: SherpaConfiguration {
        switch self {
        case .default:
            return .default
        case .minimal:
            return .minimal
        case .bold:
            return .bold
        }
    }
    
    var codeExample: String {
        switch self {
        case .default:
            return "SherpaContainerView(configuration: .default) {\n    ContentView()\n}"
        case .minimal:
            return "SherpaContainerView(configuration: .minimal) {\n    ContentView()\n}"
        case .bold:
            return "SherpaContainerView(configuration: .bold) {\n    ContentView()\n}"
        }
    }
}

// MARK: - Supporting Views

struct ConfigItem: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.App.primary)
            
            Text(title)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: AppDesign.CornerRadius.medium))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        SherpaContainerView {
            ConfigurationDemo()
        }
    }
}
