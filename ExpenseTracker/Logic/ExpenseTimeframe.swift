//
//  ExpenseTimeframe.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 30.06.26.
//

import Foundation

enum ExpenseTimeframe: String, CaseIterable, Identifiable, Equatable {
    case untilToday = "Until Today"
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"

    var id: String { rawValue }
    var title: String { rawValue }

    func contains(_ date: Date, calendar: Calendar = .current, now: Date = .now) -> Bool {
        switch self {
        case .today:
            return calendar.isDate(date, inSameDayAs: now)
        case .thisWeek:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return false }
            return interval.contains(date)
        case .thisMonth:
            guard let interval = calendar.dateInterval(of: .month, for: now) else { return false }
            return interval.contains(date)
        case .thisYear:
            guard let interval = calendar.dateInterval(of: .year, for: now) else { return false }
            return interval.contains(date)
        case .untilToday:
            let startOfToday = calendar.startOfDay(for: now)
            guard let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)?
                .addingTimeInterval(-1) else { return false }
            return date <= endOfToday
        }
    }
}
