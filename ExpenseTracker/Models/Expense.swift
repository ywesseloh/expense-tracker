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
    var price: Int
    var timestamp: Date
    
    init(title: String, price: Int, timestamp: Date) {
        self.title = title
        self.price = price
        self.timestamp = timestamp
    }
}

extension Expense {
    static var samples = [
        Expense(title: "Bread", price: 350, timestamp: .now),
        Expense(title: "Netflix", price: 1000, timestamp: .now),
        Expense(title: "Gasoline", price: 4537, timestamp: .now),
        Expense(title: "Shoes", price: 7525, timestamp: .now)
    ]
}
