import SwiftUI


struct CalculatorButton: View {
    enum ButtonStyle {
        case number
        case function
        case operation
        case equals
        var foregroundColor: Color {
            switch self {
            case .number:
                return .primary
            case .function:
                return .primary
            case .operation:
                return .white
            case .equals:
                return .white
            }
        }
        var backgroundColor: Color {
            switch self {
            case .number:
                return Color.white.opacity(0.72)
            case .function:
                return Color.white.opacity(0.42)
            case .operation:
                return Color.indigo
            case .equals:
                return Color.purple
            }
        }
    }
    let title: String?
    let systemImage: String?
    let style: ButtonStyle
    var isSelected: Bool = false
    let action: () -> Void
    @State private var isPressed = false
    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.12)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.12)) {
                    isPressed = false
                }
            }
            action()
        } label: {
            Group {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                } else if let title {
                    Text(title)
                        .font(.system(size: 25, weight: .semibold, design: .rounded))
                }
            }
            .foregroundStyle(
                isSelected
                ? Color.white
                : style.foregroundColor
            )
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(
                isSelected
                ? Color.purple
                : style.backgroundColor
            )
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(
                color: .black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.92 : 1)
        .accessibilityLabel(title ?? systemImage ?? "Кнопка")
    }
}
struct CalculatorBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(
                    red: 0.94,
                    green: 0.93,
                    blue: 1.0
                ),
                Color(
                    red: 0.84,
                    green: 0.85,
                    blue: 1.0
                )
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
