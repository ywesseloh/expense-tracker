//
//  ExpenseCategory.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 23.06.26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class ExpenseCategory {
    var title: String
    var colorHex: String
    var iconIdentifier: String
    var timestamp: Date
    
    init(title: String, colorHex: String, iconIdentifier: String, timestamp: Date = .now) {
        self.title = title
        self.colorHex = colorHex
        self.iconIdentifier = iconIdentifier
        self.timestamp = timestamp
    }
}

extension ExpenseCategory {
    static var noCategory = ExpenseCategory(title: "No Category", colorHex: Color.gray.toHex()!, iconIdentifier: "tray.fill")
    static var groceries = ExpenseCategory(title: "Groceries", colorHex: Color.cyan.toHex()!, iconIdentifier: "cart.fill")
    static var housing = ExpenseCategory(title: "Housing", colorHex: Color.red.toHex()!, iconIdentifier: "house.fill")
    static var transport = ExpenseCategory(title: "Transport", colorHex: Color.purple.toHex()!, iconIdentifier: "car.fill")
    static var shopping = ExpenseCategory(title: "Shopping", colorHex: Color.green.toHex()!, iconIdentifier: "handbag.fill")
    static var entertainment = ExpenseCategory(title: "Entertainment", colorHex: Color.orange.toHex()!, iconIdentifier: "theatermasks.fill")
    
    static var initialCategories: [ExpenseCategory] = [
        .noCategory,
        .groceries,
        .housing,
        .transport,
        .shopping,
        .entertainment
    ]
}
