//
//  CreateExpenseView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 18.06.26.
//

import SwiftUI
import SwiftData

struct CreateExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrencyManager.self) private var currencyManager

    @State private var title = ""
    @State private var priceText: String = ""
    @State private var showCancelConfirmation = false
    @State private var date: Date = .now
    
    @State private var selectedCategory: ExpenseCategory?
    
    init(initialCategory: ExpenseCategory?) {
        _selectedCategory = State(initialValue: initialCategory)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Title (Required)", text: $title)
                    TextField("Price (Required)", text: $priceText)
                        .onChange(of: priceText) { _, newValue in
                            priceText = currencyManager.formatInput(newValue)
                        }
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    NavigationLink {
                        SelectCategoryView(selectedCategory: $selectedCategory)
                    } label: {
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(selectedCategory?.title ?? "No Selection")
                        }
                        
                    }
                    DatePicker("Date", selection: $date)
                }
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        if title.isEmpty, priceText.isEmpty {
                            dismiss()
                        } else {
                            showCancelConfirmation = true
                        }
                    }
                    .confirmationDialog("Discard Expense", isPresented: $showCancelConfirmation) {
                        Button("Discard Moment", role: .destructive) {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "checkmark", action: addExpense)
                        .disabled(title.isEmpty || priceText.isEmpty)
                }
            }
        }
    }
    
    private func addExpense() {
        guard let decimalPrice = currencyManager.decimalPrice(from: priceText), let category = selectedCategory else { return }
        let newExpense = Expense(
            title: title,
            price: currencyManager.minorUnits(from: decimalPrice),
            timestamp: .now,
            category: category
        )
        modelContext.insert(newExpense)
        try? modelContext.save()
        dismiss()
    }

}

#Preview {
    CreateExpenseView(initialCategory: nil)
        .applyDependencies()
}
