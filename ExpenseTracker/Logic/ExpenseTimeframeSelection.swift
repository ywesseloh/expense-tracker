//
//  ExpenseTimeframeSelection.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 30.06.26.
//

import Foundation

enum ExpenseTimeframeSelection: Equatable {
    case preset(ExpenseTimeframe)
    case custom(start: Date, end: Date)

    func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        switch self {
        case .preset(let timeframe):
            return timeframe.contains(date)
        case .custom(let start, let end):
            let rangeStart = calendar.startOfDay(for: start)
            guard let endOfRange = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end))?
                .addingTimeInterval(-1) else { return false }
            return date >= rangeStart && date <= endOfRange
        }
    }

    var displayTitle: String {
        switch self {
        case .preset(let timeframe):
            return timeframe.title
        case .custom(let start, let end):
            let startText = start.formatted(date: .abbreviated, time: .omitted)
            let endText = end.formatted(date: .abbreviated, time: .omitted)
            return "\(startText) – \(endText)"
        }
    }
}
