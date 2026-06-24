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
    
    @State private var showCreateExpense = false
    
    @Query(sort: \Expense.timestamp)
    private var expenses: [Expense]
    
    @Query(sort: \ExpenseCategory.timestamp)
    private var categories: [ExpenseCategory]

    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { expense in
                    NavigationLink {
                        Text(expense.title)
                        Text(currencyManager.decimalPrice(from: expense.price), format: .currency(code: "EUR"))
                        Text(expense.category.title)
                    } label: {
                        Text(expense.title)
                        Text(currencyManager.decimalPrice(from: expense.price), format: .currency(code: "EUR"))
                        Text(expense.category.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showCreateExpense = true
                    }, label: {
                        Label("Add Item", systemImage: "plus")
                    })
                }
            }
            .sheet(isPresented: $showCreateExpense) {
                CreateExpenseView(initialCategory: categories.first)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(expenses[index])
            }
        }
    }
}

#Preview {    
    ContentView()
        .applyDependencies()
}
