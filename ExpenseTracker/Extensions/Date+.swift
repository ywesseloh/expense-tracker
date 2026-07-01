//
//  Date+.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 25.06.26.
//

import Foundation

extension Date {
    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
    }
    
    static var dayBeforeYesterday: Date {
        Calendar.current.date(byAdding: .day, value: -2, to: .now) ?? .now
    }
    
    static var oneMonthAgo: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    }
}

extension Calendar {
    func endOfDay(for date: Date) -> Date? {
        let startOfDay = self.startOfDay(for: date)
        return self.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1)
    }
}
