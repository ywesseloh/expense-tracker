//
//  Item.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 18.06.26.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var title: String
    var timestamp: Date
    
    init(title: String, timestamp: Date) {
        self.title = title
        self.timestamp = timestamp
    }
}

extension Expense {
    static var samples = [
        Expense(title: "Bread", timestamp: .now),
        Expense(title: "Netflix", timestamp: .now),
        Expense(title: "Gasoline", timestamp: .now),
        Expense(title: "Shoes", timestamp: .now)
    ]
}
