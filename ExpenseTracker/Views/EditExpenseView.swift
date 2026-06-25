//
//  EditExpenseView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 18.06.26.
//

import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(CurrencyManager.self) private var currencyManager

    @State private var showCancelConfirmation = false

    @State private var title = ""
    @State private var priceText: String = ""
    @State private var date: Date = .now
    @State private var selectedCategory: ExpenseCategory
    
    private var context: Context
    
    init(currencyManager: CurrencyManager, context: Context) {
        switch context {
        case .new(let initialCategory):
            _selectedCategory = State(initialValue: initialCategory)
        case .edit(let expense):
            _title = State(initialValue: expense.title)
            _priceText = State(initialValue: currencyManager.priceText(from: expense.price) ?? "")
            _date = State(initialValue: expense.timestamp)
            _selectedCategory = State(initialValue: expense.category)
        }
        self.context = context
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
                            CategoryIconView(category: selectedCategory)
                            Text(selectedCategory.title)
                        }
                        
                    }
                    DatePicker("Date", selection: $date)
                }
            }
            .navigationTitle(context.titleString)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
//                        if case title.isEmpty, priceText.isEmpty {
                            dismiss()
//                        } else {
//                            showCancelConfirmation = true
//                        }
                    }
                    .confirmationDialog("Discard Expense", isPresented: $showCancelConfirmation) {
                        Button("Discard Moment", role: .destructive) {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "checkmark", action: updateExpense)
                        .disabled(title.isEmpty || priceText.isEmpty)
                }
            }
        }
    }
    
    private func updateExpense() {
        guard let price = currencyManager.minorUnits(from: priceText) else { return }
        
        switch context {
        case .new:  // Create new expense
            let newExpense = Expense(
                title: title,
                price: price,
                timestamp: date,
                category: selectedCategory
            )
            modelContext.insert(newExpense)
            try? modelContext.save()
        case .edit(let expense):    // Edit existing expense
            expense.title = title
            expense.price = price
            expense.timestamp = date
            expense.category = selectedCategory
        }
        
        dismiss()
    }
}

extension EditExpenseView {
    enum Context: Identifiable {
        case new(initialCategory: ExpenseCategory)
        case edit(expense: Expense)
        
        var id: PersistentIdentifier {
            switch self {
            case .new(let initialCategory):
                return initialCategory.persistentModelID
            case .edit(let expense):
                return expense.persistentModelID
            }
        }
        
        var titleString: String {
            switch self {
            case .new:
                return "New Expense"
            case .edit:
                return "Edit Expense"
            }
        }
    }
}

#Preview {
    EditExpenseView(currencyManager: CurrencyManager(), context: .new(initialCategory: .noCategory))
        .applyDependencies()
}
