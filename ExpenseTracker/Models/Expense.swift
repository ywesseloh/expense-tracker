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
    var category: ExpenseCategory
    
    init(title: String, price: Int, timestamp: Date, category: ExpenseCategory) {
        self.title = title
        self.price = price
        self.timestamp = timestamp
        self.category = category
    }
}

extension Expense {
    static var samples = [
        Expense(title: "Bread", price: 350, timestamp: .now, category: ExpenseCategory.initialCategories[1]),
        Expense(title: "Netflix", price: 1000, timestamp: .now, category: ExpenseCategory.initialCategories[5]),
        Expense(title: "Gasoline", price: 4537, timestamp: .now, category: ExpenseCategory.initialCategories[3]),
        Expense(title: "Shoes", price: 7525, timestamp: .now,category:  ExpenseCategory.initialCategories[4])
    ]
}
