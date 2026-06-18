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

    @State private var title = ""
    @State private var showCancelConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Title (Required)", text: $title)
                    .font(.title.bold())
                    .padding(.top, 50)
                    .padding(.leading)
                Spacer()
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        if title.isEmpty {
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
                    Button("Add", systemImage: "checkmark") {
                        let newExpense = Expense(
                            title: title,
                            timestamp: .now
                        )
                        modelContext.insert(newExpense)
                        try? modelContext.save()
                        dismiss()
                    }.disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateExpenseView()
}
