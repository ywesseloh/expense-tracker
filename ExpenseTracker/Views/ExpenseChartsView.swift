//
//  ExpenseChartsView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 30.06.26.
//

import SwiftUI
import SwiftData
import Charts

private struct CategoryChartSlice: Identifiable {
    let id: PersistentIdentifier
    let category: ExpenseCategory
    let totalMinorUnits: Int
}

struct ExpenseChartsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CurrencyManager.self) private var currencyManager

    let filteredExpenses: [Expense]

    private var categorySlices: [CategoryChartSlice] {
        Dictionary(grouping: filteredExpenses, by: \.category)
            .map { category, expenses in
                CategoryChartSlice(
                    id: category.persistentModelID,
                    category: category,
                    totalMinorUnits: expenses.map(\.price).reduce(0, +)
                )
            }
            .sorted { $0.totalMinorUnits > $1.totalMinorUnits }
    }

    private var totalMinorUnits: Int {
        filteredExpenses.map(\.price).reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredExpenses.isEmpty {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.pie",
                        description: Text("No expenses match the current filters.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            ZStack {
                                Chart(categorySlices) { slice in
                                    SectorMark(
                                        angle: .value("Amount", slice.totalMinorUnits),
                                        innerRadius: .ratio(0.62),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(Color(hex: slice.category.colorHex))
                                }
                                .frame(height: 260)

                                VStack(spacing: 4) {
                                    Text("Total")
                                        .font(.default.weight(.bold))
                                        .foregroundStyle(.secondary)
                                    Text(
                                        currencyManager.decimalPrice(from: totalMinorUnits),
                                        format: .currency(code: currencyManager.currencyCode)
                                    )
                                    .font(.title2.bold())
                                }
                            }

                            VStack(spacing: 12) {
                                ForEach(categorySlices) { slice in
                                    HStack {
                                        CategoryIconView(category: slice.category)
                                        Text(slice.category.title)
                                        Spacer()
                                        Text(
                                            currencyManager.decimalPrice(from: slice.totalMinorUnits),
                                            format: .currency(code: currencyManager.currencyCode)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Charts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExpenseChartsView(filteredExpenses: Expense.longSamples)
        .applyDependencies(expenseSamples: Expense.longSamples)
}
