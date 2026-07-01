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
    
    @State private var showExpenseSheetWithContext: EditExpenseView.Context?
    @State private var showFilterCategorySheet = false
    
    @State private var selectedTimeframe: ExpenseTimeframe = .untilToday
    @State private var filterCategory: ExpenseCategory?
    
    @Query(sort: \Expense.timestamp, order: .reverse)
    private var allExpenses: [Expense]

    private var filteredExpenses: [Expense] {
        allExpenses.filter { expense in
            selectedTimeframe.contains(expense.timestamp) &&
            (filterCategory.flatMap { $0 == expense.category } ?? true)
        }
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
            ZStack {
                expensesListView
                if allExpenses.isEmpty {
                    emptyView
                } else if filteredExpenses.isEmpty {
                    filteredEmptyView
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showExpenseSheetWithContext = .new(initialCategory: .noCategory)
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                
                ToolbarItem(placement: .topBarLeading) {
                    toggleFilterButtonView
                }
            }
            .sheet(item: $showExpenseSheetWithContext) { context in
                EditExpenseView(currencyManager: currencyManager, context: context)
            }
            .sheet(isPresented: $showFilterCategorySheet) {
                FilterCategoryView(filterCategory: $filterCategory)
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
            showExpenseSheetWithContext = .edit(expense: expense)
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

    private var filteredEmptyView: some View {
        VStack {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 40))
                .padding()

            Text("No expenses match the current filter criteria")
                .font(.title3)
                .multilineTextAlignment(.center)
        }
    }
    var filterButtonView: some View {
        Button {
            showFilterCategorySheet = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
        }
    }
    
    @ViewBuilder
    var toggleFilterButtonView: some View {
        if filterCategory == nil {
            filterButtonView
        } else {
            filterButtonView
                .buttonStyle(.glassProminent)
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
