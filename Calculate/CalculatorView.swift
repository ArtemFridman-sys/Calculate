import SwiftUI


struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    var body: some View {
        ZStack {
            CalculatorBackground()
            VStack(spacing: 0) {
                header
                Spacer(minLength: 20)
                display
                Spacer(minLength: 24)
                keypad
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .sheet(
            isPresented: $viewModel.isShowingHistory
        ) {
            HistoryView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Calculator")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Simple and powerful")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                viewModel.toggleHistory()
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .accessibilityLabel("История вычислений")
        }
    }
    private var display: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text(viewModel.expression.isEmpty ? " " : viewModel.expression)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(viewModel.displayValue)
                .font(
                    .system(
                        size: viewModel.displayFontSize,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 4)
        .animation(.easeInOut(duration: 0.2), value: viewModel.displayValue)
    }
    private var keypad: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                CalculatorButton(
                    title: "AC",
                    systemImage: nil,
                    style: .function
                ) {
                    viewModel.clear()
                }
                CalculatorButton(
                    title: nil,
                    systemImage: "delete.left",
                    style: .function
                ) {
                    viewModel.deleteLastDigit()
                }
                CalculatorButton(
                    title: "%",
                    systemImage: nil,
                    style: .function
                ) {
                    viewModel.percentage()
                }
                CalculatorButton(
                    title: CalculatorOperation.division.symbol,
                    systemImage: nil,
                    style: .operation,
                    isSelected: isOperationSelected(.division)
                ) {
                    viewModel.inputOperation(.division)
                }
            }
            HStack(spacing: 14) {
                numberButton("7")
                numberButton("8")
                numberButton("9")
                operationButton(.multiplication)
            }
            HStack(spacing: 14) {
                numberButton("4")
                numberButton("5")
                numberButton("6")
                operationButton(.subtraction)
            }
            HStack(spacing: 14) {
                numberButton("1")
                numberButton("2")
                numberButton("3")
                operationButton(.addition)
            }
            HStack(spacing: 14) {
                CalculatorButton(
                    title: "+/−",
                    systemImage: nil,
                    style: .number
                ) {
                    viewModel.toggleSign()
                }
                numberButton("0")
                CalculatorButton(
                    title: ".",
                    systemImage: nil,
                    style: .number
                ) {
                    viewModel.inputDecimalSeparator()
                }
                CalculatorButton(
                    title: "=",
                    systemImage: nil,
                    style: .equals
                ) {
                    viewModel.calculateResult()
                }
            }
        }
    }
    private func numberButton(_ value: String) -> some View {
        CalculatorButton(
            title: value,
            systemImage: nil,
            style: .number
        ) {
            viewModel.inputDigit(value)
        }
    }
    private func operationButton(_ operation: CalculatorOperation) -> some View {
        CalculatorButton(
            title: operation.symbol,
            systemImage: nil,
            style: .operation,
            isSelected: isOperationSelected(operation)
        ) {
            viewModel.inputOperation(operation)
        }
    }
    private func isOperationSelected(_ operation: CalculatorOperation) -> Bool {
        viewModel.selectedOperation == operation
    }
}
