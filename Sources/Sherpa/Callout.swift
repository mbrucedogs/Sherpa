//
//  Callout.swift
//  Sherpa
//
//  Callout tooltip components for the Sherpa framework.
//

import SwiftUI

// MARK: - Callout

@MainActor
public struct Callout {
    
    // MARK: - Factory Methods
    
    /// Creates a simple text callout
    public static func text(_ text: String, edge: Edge = .top) -> Self {
        .bubble(edge: edge) { 
            Text(text)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
    
    /// Creates a text callout with an "Ok!" button
    public static func okText(_ text: String, edge: Edge = .top) -> Self {
        .bubble(edge: edge) {
            HStack {
                Text(text)
                    .padding(.trailing, Design.Spacing.xSmall)
                Color.black.frame(width: Design.LineWidth.thin)
                Text(sherpa: SherpaStrings.ok)
                    .bold()
                    .padding(.leading, Design.Spacing.xSmall)
            }
            .fixedSize()
        }
    }
    
    /// Creates a callout with an icon and text
    public static func labeled(_ text: String, systemImage: String, edge: Edge = .top) -> Self {
        .bubble(edge: edge) {
            Label(text, systemImage: systemImage)
                .fixedSize()
        }
    }
    
    /// Creates a callout inside the default bubble style
    public static func bubble<V: View>(edge: Edge = .top, @ViewBuilder content: () -> V) -> Self {
        let inside = content()
        let bodyBlock: (@escaping () -> Void) -> AnyView = { onTap in
            AnyView(
                Button(action: onTap) {
                    inside.padding(Design.Spacing.small)
                }
                .buttonStyle(CalloutButtonStyle(edge: edge))
                .accessibilityAddTraits(.isButton)
            )
        }
        
        return .init(body: bodyBlock, edge: edge)
    }
    
    /// Creates a fully custom callout view
    public static func custom<V: View>(edge: Edge = .top, @ViewBuilder content: @escaping (_ onTap: @escaping () -> Void) -> V) -> Self {
        .init(body: { onTap in AnyView(content(onTap)) }, edge: edge)
    }
    
    // MARK: - Properties
    
    public let body: (_ onTap: @escaping () -> Void) -> AnyView
    public let edge: Edge
    
    // MARK: - Internal
    
    func createView(onTap: @escaping () -> Void) -> some View {
        body(onTap)
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: CalloutPreferenceKey.self, value: proxy.size)
                }
            }
    }
}

// MARK: - CalloutBubble Shape

struct CalloutBubble: Shape {
    let edge: Edge
    var pointerOffset: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let pointerWidth = Design.Size.calloutPointerWidth
        let pointerHeight = Design.Size.calloutPointerHeight
        let cornerRadius = Design.Size.calloutCornerRadius
        
        var path = Path()
        
        let minPointerX = cornerRadius + pointerWidth / 2
        let maxPointerX = rect.width - cornerRadius - pointerWidth / 2
        let minPointerY = cornerRadius + pointerWidth / 2
        let maxPointerY = rect.height - cornerRadius - pointerWidth / 2
        
        let (points, frame): ([CGPoint], CGRect) = switch edge {
        case .bottom:
            {
                let pointerX = min(max(rect.width / 2 + pointerOffset, minPointerX), maxPointerX)
                return ([
                    .init(x: pointerX - pointerWidth / 2, y: pointerHeight),
                    .init(x: pointerX + pointerWidth / 2, y: pointerHeight),
                    .init(x: pointerX, y: 0)
                ],
                .init(x: 0, y: pointerHeight, width: rect.width, height: rect.height - pointerHeight))
            }()
        case .top:
            {
                let pointerX = min(max(rect.width / 2 + pointerOffset, minPointerX), maxPointerX)
                return ([
                    .init(x: pointerX - pointerWidth / 2, y: rect.height - pointerHeight),
                    .init(x: pointerX + pointerWidth / 2, y: rect.height - pointerHeight),
                    .init(x: pointerX, y: rect.height)
                ],
                .init(x: 0, y: 0, width: rect.width, height: rect.height - pointerHeight))
            }()
        case .leading:
            {
                let pointerY = min(max(rect.height / 2 + pointerOffset, minPointerY), maxPointerY)
                return ([
                    .init(x: rect.width - pointerHeight, y: pointerY - pointerWidth / 2),
                    .init(x: rect.width - pointerHeight, y: pointerY + pointerWidth / 2),
                    .init(x: rect.width, y: pointerY)
                ],
                .init(x: 0, y: 0, width: rect.width - pointerHeight, height: rect.height))
            }()
        case .trailing:
            {
                let pointerY = min(max(rect.height / 2 + pointerOffset, minPointerY), maxPointerY)
                return ([
                    .init(x: pointerHeight, y: pointerY - pointerWidth / 2),
                    .init(x: pointerHeight, y: pointerY + pointerWidth / 2),
                    .init(x: 0, y: pointerY)
                ],
                .init(x: pointerHeight, y: 0, width: rect.width - pointerHeight, height: rect.height))
            }()
        }
        
        path.move(to: points.last!)
        path.addLines(points)
        path.addRoundedRect(in: frame, cornerSize: .init(width: cornerRadius, height: cornerRadius))
        return path
    }
}

// MARK: - Pointer Offset Environment

private struct PointerOffsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var calloutPointerOffset: CGFloat {
        get { self[PointerOffsetKey.self] }
        set { self[PointerOffsetKey.self] = newValue }
    }
}

// MARK: - CalloutButtonStyle

struct CalloutButtonStyle: ButtonStyle {
    let edge: Edge
    @Environment(\.calloutPointerOffset) private var pointerOffset
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            if edge == .bottom {
                Color.clear.frame(width: Design.LineWidth.thin, height: Design.Size.calloutPointerHeight)
            }
            
            HStack {
                if edge == .trailing {
                    Color.clear.frame(width: Design.Size.calloutPointerHeight, height: Design.LineWidth.thin)
                }
                configuration.label
                if edge == .leading {
                    Color.clear.frame(width: Design.Size.calloutPointerHeight, height: Design.LineWidth.thin)
                }
            }
            
            if edge == .top {
                Color.clear.frame(width: Design.LineWidth.thin, height: Design.Size.calloutPointerHeight)
            }
        }
        .background(
            CalloutBubble(edge: edge, pointerOffset: pointerOffset)
                .fill(configuration.isPressed ? Color.Sherpa.calloutPressed : Color.Sherpa.calloutBackground)
                .shadow(color: Color.Sherpa.calloutShadow, radius: Design.Shadow.radiusLarge, x: 0, y: Design.Shadow.offsetMedium)
        )
        .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: Design.Animation.quick), value: configuration.isPressed)
    }
}

// MARK: - Preference Key

struct CalloutPreferenceKey: PreferenceKey {
    typealias Value = CGSize

    static let defaultValue: Value = .zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview("Callout Bubbles") {
    VStack(spacing: Design.Spacing.xLarge) {
        CalloutBubble(edge: .bottom)
            .fill(Color.Sherpa.calloutBackground)
            .shadow(radius: Design.Shadow.radiusMedium)
            .frame(width: 120, height: 60)
        CalloutBubble(edge: .top)
            .fill(Color.Sherpa.calloutBackground)
            .shadow(radius: Design.Shadow.radiusMedium)
            .frame(width: 120, height: 60)
        CalloutBubble(edge: .leading)
            .fill(Color.Sherpa.calloutBackground)
            .shadow(radius: Design.Shadow.radiusMedium)
            .frame(width: 120, height: 60)
        CalloutBubble(edge: .trailing)
            .fill(Color.Sherpa.calloutBackground)
            .shadow(radius: Design.Shadow.radiusMedium)
            .frame(width: 120, height: 60)
    }
    .padding()
    .background(Color.gray.opacity(Design.Opacity.hint))
}
