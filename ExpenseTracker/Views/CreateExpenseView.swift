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
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Title (Required)", text: $title)
                    .font(.title.bold())
                    .padding(.top, 50)
                    .padding(.leading)
                HStack {
                    Text(currencyManager.currencySymbol)
                    TextField("Price (Required)", text: $priceText)
                        .onChange(of: priceText) { _, newValue in
                            priceText = currencyManager.formatInput(newValue)
                        }
                        .keyboardType(.decimalPad)
                }
                .font(.title)
                .padding()
                Spacer()
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
        guard let decimalPrice = currencyManager.decimalPrice(from: priceText) else { return }
        let newExpense = Expense(
            title: title,
            price: currencyManager.minorUnits(from: decimalPrice),
            timestamp: .now
        )
        modelContext.insert(newExpense)
        try? modelContext.save()
        dismiss()
    }

}

#Preview {
    CreateExpenseView()
        .previewDependencies()
}
