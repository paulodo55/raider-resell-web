import SwiftUI

struct TexasTechTheme {
    // Texas Tech Colors
    static let primaryRed = Color(red: 204/255, green: 9/255, blue: 47/255) // Texas Tech Red
    static let secondaryRed = Color(red: 178/255, green: 8/255, blue: 41/255) // Darker Red
    static let black = Color(red: 33/255, green: 33/255, blue: 33/255) // Texas Tech Black
    static let white = Color.white
    static let lightGray = Color(red: 245/255, green: 245/255, blue: 245/255)
    static let mediumGray = Color(red: 128/255, green: 128/255, blue: 128/255)
    static let darkGray = Color(red: 64/255, green: 64/255, blue: 64/255)
    
    // Accent Colors
    static let gold = Color(red: 255/255, green: 215/255, blue: 0/255)
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [primaryRed, secondaryRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [white, lightGray],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Shadow
    static let cardShadow = Color.black.opacity(0.1)
}

// MARK: - Custom ViewModifiers

struct TexasTechButtonStyle: ButtonStyle {
    let variant: ButtonVariant
    
    enum ButtonVariant {
        case primary, secondary, outline, text
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundForVariant(configuration.isPressed))
            .foregroundColor(foregroundColorForVariant())
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColorForVariant(), lineWidth: variant == .outline ? 2 : 0)
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func backgroundForVariant(_ isPressed: Bool) -> Color {
        switch variant {
        case .primary:
            return isPressed ? TexasTechTheme.secondaryRed : TexasTechTheme.primaryRed
        case .secondary:
            return isPressed ? TexasTechTheme.lightGray : TexasTechTheme.mediumGray
        case .outline, .text:
            return isPressed ? TexasTechTheme.lightGray : Color.clear
        }
    }
    
    private func foregroundColorForVariant() -> Color {
        switch variant {
        case .primary:
            return TexasTechTheme.white
        case .secondary:
            return TexasTechTheme.white
        case .outline:
            return TexasTechTheme.primaryRed
        case .text:
            return TexasTechTheme.primaryRed
        }
    }
    
    private func borderColorForVariant() -> Color {
        switch variant {
        case .outline:
            return TexasTechTheme.primaryRed
        default:
            return Color.clear
        }
    }
}

struct TexasTechCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(TexasTechTheme.white)
            .cornerRadius(12)
            .shadow(color: TexasTechTheme.cardShadow, radius: 8, x: 0, y: 2)
    }
}

struct TexasTechTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(TexasTechTheme.lightGray)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(TexasTechTheme.mediumGray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - View Extensions

extension View {
    func texasTechCard() -> some View {
        self.modifier(TexasTechCardStyle())
    }
    
    func primaryButton() -> some View {
        self.buttonStyle(TexasTechButtonStyle(variant: .primary))
    }
    
    func secondaryButton() -> some View {
        self.buttonStyle(TexasTechButtonStyle(variant: .secondary))
    }
    
    func outlineButton() -> some View {
        self.buttonStyle(TexasTechButtonStyle(variant: .outline))
    }
    
    func textButton() -> some View {
        self.buttonStyle(TexasTechButtonStyle(variant: .text))
    }
    
    func texasTechTextField() -> some View {
        self.textFieldStyle(TexasTechTextFieldStyle())
    }
}

// MARK: - Typography

struct TexasTechTypography {
    static let largeTitle = Font.system(size: 32, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    static let headline = Font.system(size: 18, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let callout = Font.system(size: 15, weight: .regular)
    static let subheadline = Font.system(size: 14, weight: .regular)
    static let footnote = Font.system(size: 12, weight: .regular)
    static let caption1 = Font.system(size: 11, weight: .regular)
    static let caption2 = Font.system(size: 10, weight: .regular)
} 