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
    @State private var showCustomTimeframeSheet = false
    
    @State private var timeframeSelection: ExpenseTimeframeSelection = .preset(.untilToday)
    @State private var filterCategory: ExpenseCategory?
    @State private var searchText = ""
    
    @Query(sort: \Expense.timestamp, order: .reverse)
    private var allExpenses: [Expense]

    private var filteredExpenses: [Expense] {
        allExpenses.filter { expense in
            timeframeSelection.contains(expense.timestamp) &&
            (filterCategory.flatMap { $0 == expense.category } ?? true) &&
            matchesSearch(expense)
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
            .safeAreaInset(edge: .bottom) {
                floatingBottomBar
            }
            .sheet(item: $showExpenseSheetWithContext) { context in
                EditExpenseView(currencyManager: currencyManager, context: context)
            }
            .sheet(isPresented: $showFilterCategorySheet) {
                FilterCategoryView(filterCategory: $filterCategory)
            }
            .sheet(isPresented: $showCustomTimeframeSheet) {
                CustomTimeframeView(timeframeSelection: $timeframeSelection)
            }
        }
    }
    
    private var expensesListView: some View {
        List {
            VStack(alignment: .leading, spacing: 8) {
                Menu {
                    ForEach(ExpenseTimeframe.allCases) { timeframe in
                        Button(timeframe.title) {
                            timeframeSelection = .preset(timeframe)
                        }
                    }
                    Button("Custom") {
                        showCustomTimeframeSheet = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(timeframeSelection.displayTitle)
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
        .animation(.default, value: searchText)
        .animation(.default, value: timeframeSelection)
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
    private var floatingBottomBar: some View {
        HStack(spacing: 12) {
            toggleFilterButtonView

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                TextField(
                    "Search",
                    text: $searchText,
                    prompt: Text("Search").foregroundColor(.gray).bold()
                )
                .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .glassEffect()

            Button {
                showExpenseSheetWithContext = .new(initialCategory: .noCategory)
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .frame(width: 35, height: 35)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    var filterButtonView: some View {
        Button {
            showFilterCategorySheet = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.title2.weight(.semibold))
                .frame(width: 35, height: 35)
        }
        .buttonBorderShape(.circle)
    }
    
    @ViewBuilder
    var toggleFilterButtonView: some View {
        if filterCategory == nil {
            filterButtonView
                .buttonStyle(.glass)
        } else {
            filterButtonView
                .buttonStyle(.glassProminent)
            
        }
    }

    private func matchesSearch(_ expense: Expense) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }

        let titleMatches = expense.title.localizedCaseInsensitiveContains(query)
        let priceMatches = (currencyManager.priceText(from: expense.price) ?? "")
            .localizedCaseInsensitiveContains(query)

        return titleMatches || priceMatches
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
