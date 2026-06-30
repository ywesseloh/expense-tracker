//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 18.06.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrencyManager.self) private var currencyManager
    
    @State private var showSheetWithContext: EditExpenseView.Context?
    @State private var selectedTimeframe: ExpenseTimeframe = .untilToday
    
    @Query(sort: \Expense.timestamp, order: .reverse)
    private var allExpenses: [Expense]

    private var filteredExpenses: [Expense] {
        allExpenses.filter { selectedTimeframe.contains($0.timestamp) }
    }
        
    private var expensesByDate: [Date: [Expense]] {
        Dictionary(grouping: filteredExpenses) { expense in
            Calendar.current.startOfDay(for: expense.timestamp)
        }
    }

    var groupedExpenses: [(date: Date, expenses: [Expense])] {
        expensesByDate
            .map { (date: $0.key, expenses: $0.value) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    expensesListView
                    if allExpenses.isEmpty {
                        emptyView
                    } else if filteredExpenses.isEmpty {
                        Text("No expenses found for these filter criteria")
                    }
                }
                Button {
                    showSheetWithContext = .new(initialCategory: .noCategory)
                } label: {
                    FloatingButtonView(backgroundColor: .blue, foregroundColor: .white, imageName: "plus")
                }
                .padding()
            }
            .sheet(item: $showSheetWithContext) { context in
                EditExpenseView(currencyManager: currencyManager, context: context)
            }
        }
    }
    
    private var expensesListView: some View {
        List {
            VStack(alignment: .leading, spacing: 8) {
                Menu {
                    ForEach(ExpenseTimeframe.allCases) { timeframe in
                        Button(timeframe.title) {
                            selectedTimeframe = timeframe
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedTimeframe.title)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                }

                Text(
                    currencyManager.decimalPrice(from: sum(expenses: filteredExpenses)),
                    format: .currency(code: currencyManager.currencyCode)
                )
                .font(.title)
            }
            .padding()
            
            ForEach(groupedExpenses.enumerated(), id: \.offset) { index, group in
                Section(header: dateHeaderview(date: group.date)) {
                    ForEach(group.expenses) { expense in
                        expenseRowView(expense: expense)
                    }.onDelete { offsets in
                        deleteItems(sectionIndex: index, offsets: offsets)
                    }
                }
            }
        }
    }
    
    private func dateHeaderview(date: Date) -> some View {
        HStack {
            Text(date, style: .date)
            Spacer()
            Text(
                currencyManager.decimalPrice(from: sum(expenses: expensesByDate[date] ?? [])),
                format: .currency(code: currencyManager.currencyCode)
            )
        }
    }
    
    private func expenseRowView(expense: Expense) -> some View {
        Button {
            showSheetWithContext = .edit(expense: expense)
        } label: {
            HStack {
                CategoryIconView(category: expense.category)
                Text(expense.title)
                Spacer()
                Text(
                    currencyManager.decimalPrice(from: expense.price),
                    format: .currency(code: currencyManager.currencyCode)
                )
            }
        }.tint(.primary)
    }
    
    private var emptyView: some View {
        VStack {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .padding()
            
            Text("Add your first expense by tapping the plus Button")
                .font(.title3)
                .multilineTextAlignment(.center)
        }
    }

    private func deleteItems(sectionIndex: Int, offsets: IndexSet) {
        let group = groupedExpenses[sectionIndex]
        
        for index in offsets {
            let expense = group.expenses[index]
            modelContext.delete(expense)
        }
    }
    
    private func sum(expenses: [Expense]) -> Int {
        return expenses
            .map { $0.price }
            .reduce(0, +)
    }
}

#Preview("Long List") {
    ContentView()
        .applyDependencies(expenseSamples: Expense.longSamples)
}

#Preview("Short List") {
    ContentView()
        .applyDependencies(expenseSamples: Expense.shortSamples)
}

#Preview("No entries") {
    ContentView()
        .applyDependencies()
}
