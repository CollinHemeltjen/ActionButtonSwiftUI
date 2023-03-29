//
//  ActionButton.swift
//  button test swiftui
//
//  Created by Collin Hemeltjen on 29/03/2023.
//

import SwiftUI

struct ActionButton: View {
    init(
        appearance: ActionButtonAppearance,
        label: String? = nil,
        icon: Image? = nil,
        onTapDown: @escaping () -> Void = {},
        onTapUp: @escaping () -> Void = {}
    ) {
        self.appearance = appearance
        self.label = label
        self.icon = icon
        self.onTapDown = onTapDown
        self.onTapUp = onTapUp
    }

    var appearance: ActionButtonAppearance
    var label: String?
    var icon: Image?

    /// Makes it possible to add actions to the touch down.
    var onTapDown: () -> Void = {}

    /// We work with an on tap up instead of an on tap because we want to be able to cancel the action
    /// when the user drags away from the button.
    var onTapUp: () -> Void = {}

    @State private var pressed = false
    @State private var size: CGRect = CGRect()

    var body: some View {
        let backgroundColor = pressed ? appearance.pressedColor : appearance.restColor

        let content = HStack {
            if let icon {
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
            }
            if let label {
                Text(label)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { action in
                let inside = action.location.x > 0 && action.location.x < size.width && action.location.y > 0 && action.location.y < size.height
                if inside {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.pressed = true
                        onTapDown()
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.pressed = false
                    }
                }
            }
            .onEnded { action in
                let inside = action.location.x > 0 && action.location.x < size.width && action.location.y > 0 && action.location.y < size.height

                if inside {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.pressed = false
                        onTapUp()
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.pressed = false
                    }
                }

            }

        return content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(appearance.borderColor, lineWidth: 2)
                )
                .shadow(color: appearance.restColor.opacity(33), radius: 24, x: 0, y: 2)
                .scaleEffect(pressed ? 0.9 : 1)
                .gesture(gesture)
                .overlay(GeometryGetter(rect: $size))
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        return ActionButton(appearance: .red, label: "Big important button")
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { (g) -> Color in
            DispatchQueue.main.async { // avoids warning: 'Modifying state during view update.' Doesn't look very reliable, but works.
                self.rect = g.frame(in: .global)
            }
            return Color.clear
        }
    }
}

enum ActionButtonAppearance {
    case red, blue, emerald

    var restColor: Color {
        switch self {
        case .red:
            return Color(red: 239 / 255, green: 68 / 255, blue: 68 / 255)
        case .blue:
            return Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)
        case .emerald:
            return Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)
        }
    }

    var pressedColor: Color {
        switch self {
        case .red:
            return Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255)
        case .blue:
            return Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255)
        case .emerald:
            return Color(red: 5 / 255, green: 150 / 255, blue: 105 / 255)
        }
    }

    var borderColor: Color {
        switch self {
        case .red:
            return Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255)
        case .blue:
            return Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255)
        case .emerald:
            return Color(red: 5 / 255, green: 150 / 255, blue: 105 / 255)
        }
    }
}
