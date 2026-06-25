//
//  Date+.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 25.06.26.
//

import Foundation

extension Date {
    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    }
    
    static var dayBeforeYesterday: Date {
        Calendar.current.date(byAdding: .day, value: -2, to: .now)!
    }
}
