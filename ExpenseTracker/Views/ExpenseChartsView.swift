//
//  ExpenseChartsView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 30.06.26.
//

import SwiftUI

struct ExpenseChartsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Charts Coming Soon",
                systemImage: "chart.bar",
                description: Text("Expense visualizations will appear here.")
            )
            .navigationTitle("Charts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExpenseChartsView()
}
