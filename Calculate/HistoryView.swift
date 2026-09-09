import SwiftUI


struct HistoryView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    var body: some View {
        
        NavigationStack {
            Group {
                if viewModel.history.isEmpty {
                    ContentUnavailableView(
                        "История пуста",
                        systemImage: "clock",
                        description: Text("Результаты вычислений появятся здесь")
                    )
                } else {
                    List {
                        ForEach(viewModel.history) { record in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(record.expression)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.secondary)
                                Text(record.result)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete { indexes in
                            viewModel.history.remove(atOffsets: indexes)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("История")
            .toolbar {
                if !viewModel.history.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Очистить") {
                            viewModel.clearHistory()
                        }
                    }
                }
            }
        }
    }
}
