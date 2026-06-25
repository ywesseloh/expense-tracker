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
    
    @Query(sort: \ExpenseCategory.timestamp)
    private var categories: [ExpenseCategory]
    
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
            .toolbar {
                ToolbarItem {
                    Button {
                        guard let category = categories.first else { return }
                        showSheetWithContext = .new(initialCategory: category)
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $showSheetWithContext) { context in
                EditExpenseView(currencyManager: currencyManager, context: context)
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
                Text(expense.title).contentShape(Rectangle())
                Spacer()
                Text(
                    currencyManager.decimalPrice(from: expense.price),
                    format: .currency(code: currencyManager.currencyCode)
                )
            }
        }.tint(.primary)
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

#Preview {    
    ContentView()
        .applyDependencies()
}
