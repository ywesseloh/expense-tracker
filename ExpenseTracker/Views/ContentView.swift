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
    
    @Query(sort: \Expense.timestamp)
    private var expenses: [Expense]
        
    private var expensesByDate: [Date: [Expense]] {
        Dictionary(grouping: expenses) { expense in
            Calendar.current.startOfDay(for: expense.timestamp)
        }
    }
    
    private var sortedDates: [Date] {
        expensesByDate.keys.sorted(by: >)  // descending
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    expensesListView
                    if(expenses.isEmpty) {
                        emptyView
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
            HStack {
                Text(
                    currencyManager.decimalPrice(from: sum(expenses: expenses)),
                    format: .currency(code: currencyManager.currencyCode)
                )
                .font(.title)
                .padding()
            }
            
            ForEach(sortedDates, id: \.self) { date in
                Section(header: dateHeaderview(date: date)) {
                    ForEach(expensesByDate[date] ?? []) { expense in
                        expenseRowView(expense: expense)
                    }.onDelete(perform: deleteItems)
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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(expenses[index])
            }
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
