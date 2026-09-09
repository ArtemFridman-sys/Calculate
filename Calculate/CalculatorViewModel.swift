import Foundation
import SwiftUI
internal import Combine

@MainActor
final class CalculatorViewModel: ObservableObject {
    @Published private(set) var displayValue: String = "0"
    @Published private(set) var expression: String = ""
    @Published private(set) var selectedOperation: CalculatorOperation?
    var isShowingHistory: Bool = false
    var history: [CalculationRecord] = []
    private var storedValue: Decimal?
    private var waitingForOperand = false
    private var shouldResetDisplay = false
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 12
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    var displayFontSize: CGFloat {
        displayValue.count > 10 ? 42 : 64
    }
    var currentNumericValue: Decimal {
        Decimal(string: displayValue) ?? 0
    }
    func inputDigit(_ digit: String) {
        if displayValue == "Error" || waitingForOperand || shouldResetDisplay {
            displayValue = digit
            waitingForOperand = false
            shouldResetDisplay = false
            return
        }
        if displayValue == "0" {
            displayValue = digit
        } else if displayValue.count < 15 {
            displayValue += digit
        }
    }
    func inputDecimalSeparator() {
        if displayValue == "Error" || waitingForOperand || shouldResetDisplay {
            displayValue = "0."
            waitingForOperand = false
            shouldResetDisplay = false
            return
        }
        if !displayValue.contains(".") {
            displayValue += "."
        }
    }
    func inputOperation(_ operation: CalculatorOperation) {
        guard displayValue != "Error" else {
            clear()
            return
        }
        if let currentOperation = selectedOperation,
           let storedValue,
           !waitingForOperand {
            let result = calculate(
                left: storedValue,
                right: currentNumericValue,
                operation: currentOperation
            )
            guard let result else {
                showError()
                return
            }
            self.storedValue = result
            displayValue = formatted(result)
        } else {
            storedValue = currentNumericValue
        }
        selectedOperation = operation
        waitingForOperand = true
        shouldResetDisplay = false
        expression = "\(formatted(storedValue ?? 0)) \(operation.symbol)"
    }
    func calculateResult() {
        guard let operation = selectedOperation,
              let storedValue else {
            return
        }
        let rightValue = currentNumericValue
        guard let result = calculate(
            left: storedValue,
            right: rightValue,
            operation: operation
        ) else {
            showError()
            return
        }
        let leftText = formatted(storedValue)
        let rightText = formatted(rightValue)
        let resultText = formatted(result)
        expression = "\(leftText) \(operation.symbol) \(rightText) ="
        displayValue = resultText
        history.insert(
            CalculationRecord(
                expression: "\(leftText) \(operation.symbol) \(rightText)",
                result: resultText
            ),
            at: 0
        )
        self.storedValue = nil
        selectedOperation = nil
        waitingForOperand = false
        shouldResetDisplay = true
    }
    func clear() {
        displayValue = "0"
        expression = ""
        selectedOperation = nil
        storedValue = nil
        waitingForOperand = false
        shouldResetDisplay = false
    }
    func deleteLastDigit() {
        guard displayValue != "0",
              displayValue != "Error",
              !waitingForOperand else {
            return
        }
        displayValue.removeLast()
        if displayValue.isEmpty || displayValue == "-" {
            displayValue = "0"
        }
    }
    func toggleSign() {
        guard displayValue != "0",
              displayValue != "Error" else {
            return
        }
        if displayValue.hasPrefix("-") {
            displayValue.removeFirst()
        } else {
            displayValue = "-" + displayValue
        }
    }
    func percentage() {
        guard displayValue != "Error" else {
            return
        }
        let value = currentNumericValue / 100
        displayValue = formatted(value)
    }
    func toggleHistory() {
        isShowingHistory.toggle()
    }
    func clearHistory() {
        history.removeAll()
    }
    private func calculate(
        left: Decimal,
        right: Decimal,
        operation: CalculatorOperation
    ) -> Decimal? {
        switch operation {
        case .addition:
            return left + right
        case .subtraction:
            return left - right
        case .multiplication:
            return left * right
        case .division:
            guard right != 0 else {
                return nil
            }
            return left / right
        }
    }
    private func showError() {
        displayValue = "Error"
        expression = "Cannot divide by zero"
        selectedOperation = nil
        storedValue = nil
        waitingForOperand = false
        shouldResetDisplay = true
    }
    private func formatted(_ value: Decimal) -> String {
        formatter.string(from: value as NSNumber) ?? "0"
    }
}
enum CalculatorOperation: String, CaseIterable {
    case addition
    case subtraction
    case multiplication
    case division
    var symbol: String {
        switch self {
        case .addition:
            return "+"
        case .subtraction:
            return "−"
        case .multiplication:
            return "×"
        case .division:
            return "÷"
        }
    }
    var accessibilityLabel: String {
        switch self {
        case .addition:
            return "Сложение"
        case .subtraction:
            return "Вычитание"
        case .multiplication:
            return "Умножение"
        case .division:
            return "Деление"
        }
    }
}
struct CalculationRecord: Identifiable {
    let id = UUID()
    let expression: String
    let result: String
}
