import SwiftUI

enum EmberColor {
    static let accent = Color(red: 0.761, green: 0.255, blue: 0.047)
    static let paper = Color(red: 0.984, green: 0.965, blue: 0.941)
    static let ink = Color(red: 0.110, green: 0.098, blue: 0.090)
}

struct EmberPrimaryButton: ButtonStyle {
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(enabled ? EmberColor.accent : EmberColor.accent.opacity(0.35), in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
            .opacity(configuration.isPressed ? 0.86 : 1)
    }
}

struct EmberSecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(EmberColor.accent, lineWidth: 1.5))
            .foregroundStyle(EmberColor.accent)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

func clock(_ seconds: Int) -> String {
    let safe = max(0, seconds)
    return String(format: "%d:%02d", safe / 60, safe % 60)
}
