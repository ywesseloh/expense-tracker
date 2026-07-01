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
    var currencyCode: String
    
    init(title: String, price: Int, timestamp: Date, category: ExpenseCategory, currencyCode: String = "EUR") {
        self.title = title
        self.price = price
        self.timestamp = timestamp
        self.category = category
        self.currencyCode = currencyCode
    }
}

extension Expense {
    static var shortSamples = [
        Expense(title: "Bread", price: 350, timestamp: .now, category: .groceries),
        Expense(title: "Netflix", price: 1000, timestamp: .now, category: .entertainment),
        Expense(title: "Gasoline", price: 4537, timestamp: .now, category: .transport),
        Expense(title: "Shoes", price: 7525, timestamp: .now,category: .shopping)
    ]
    
    static var longSamples = [
        Expense(title: "Bread", price: 350, timestamp: .now, category: .groceries),
        Expense(title: "Netflix", price: 1000, timestamp: .now, category: .entertainment),
        Expense(title: "Gasoline", price: 4537, timestamp: .now, category: .transport),
        Expense(title: "Shoes", price: 7525, timestamp: .now,category:  .shopping),
        Expense(title: "Tomato", price: 340, timestamp: .yesterday, category: .groceries),
        Expense(title: "Playstation", price: 40000, timestamp: .yesterday, category: .entertainment),
        Expense(title: "Toothbrush", price: 7525, timestamp: .yesterday, category:  .noCategory),
        Expense(title: "Tshirt", price: 7525, timestamp: .dayBeforeYesterday, category: .shopping),
        Expense(title: "Rent", price: 70000, timestamp: .dayBeforeYesterday,category:  .housing)
    ]
}
