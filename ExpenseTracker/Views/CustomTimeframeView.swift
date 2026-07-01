//
//  CustomTimeframeView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 30.06.26.
//

import SwiftUI

struct CustomTimeframeView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var timeframeSelection: ExpenseTimeframeSelection
    @State private var startDate = Calendar.current.startOfDay(for: .oneMonthAgo)
    @State private var endDate = Calendar.current.endOfDay(for: .now) ?? .now

    init(timeframeSelection: Binding<ExpenseTimeframeSelection>) {
        self._timeframeSelection = timeframeSelection
        
        if case .custom(let start, let end) = timeframeSelection.wrappedValue {
            _startDate = State(initialValue: start)
            _endDate = State(initialValue: end)
        }
    }
    
    private var isValidRange: Bool {
        startDate <= endDate
    }

    var body: some View {
        NavigationStack {
            List {
                DatePicker(
                    "Start Date",
                    selection: $startDate,
                    displayedComponents: .date
                )
                DatePicker(
                    "End Date",
                    selection: $endDate,
                    displayedComponents: .date
                )
            }
            .navigationTitle("Custom Timeframe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm", systemImage: "checkmark") {
                        timeframeSelection = .custom(start: startDate, end: endDate)
                        dismiss()
                    }
                    .disabled(!isValidRange)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var timeFrameSelection: ExpenseTimeframeSelection = .preset(.today)
    
    CustomTimeframeView(
        timeframeSelection: $timeFrameSelection,
    )
}
