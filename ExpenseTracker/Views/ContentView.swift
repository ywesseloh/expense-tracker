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

    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { expense in
                    Button {
                        showSheetWithContext = .edit(expense: expense)
                    } label: {
                        HStack {
                            Text(expense.title).contentShape(Rectangle())
                            Text(currencyManager.decimalPrice(from: expense.price), format: .currency(code: "EUR"))
                            Text(expense.category.title)
                            Spacer()
                        }
                    }.tint(.primary)
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showSheetWithContext = .new(initialCategory: categories.first!)
                    }, label: {
                        Label("Add Item", systemImage: "plus")
                    })
                }
            }
            .sheet(item: $showSheetWithContext) { context in
                EditExpenseView(currencyManager: currencyManager, context: context)
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
