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

    @State private var title: String
    @State private var priceText: String
    @State private var date: Date
    @State private var selectedCategory: ExpenseCategory

    private let initialState: InitialState
    private let context: Context

    private var hasUnsavedChanges: Bool {
        title != initialState.title ||
        priceText != initialState.priceText ||
        date != initialState.date ||
        selectedCategory != initialState.category
    }
    
    init(currencyManager: CurrencyManager, context: Context) {
        let initialState = InitialState(context: context, currencyManager: currencyManager)

        _title = State(initialValue: initialState.title)
        _priceText = State(initialValue: initialState.priceText)
        _date = State(initialValue: initialState.date)
        _selectedCategory = State(initialValue: initialState.category)
        
        self.initialState = initialState
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
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(context.titleString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        if hasUnsavedChanges {
                            showCancelConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                    .confirmationDialog("Discard Changes", isPresented: $showCancelConfirmation) {
                        Button("Discard Changes", role: .destructive) {
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
    
    struct InitialState {
        let title: String
        let priceText: String
        let date: Date
        let category: ExpenseCategory
        
        init(context: Context, currencyManager: CurrencyManager) {
            switch context {
            case .new(let category):
                title = ""
                priceText = ""
                date = .now
                self.category = category
            case .edit(let expense):
                title = expense.title
                priceText = currencyManager.priceText(from: expense.price) ?? ""
                date = expense.timestamp
                category = expense.category
            }
        }
    }
}

#Preview {
    EditExpenseView(currencyManager: CurrencyManager(), context: .new(initialCategory: .noCategory))
        .applyDependencies()
}
