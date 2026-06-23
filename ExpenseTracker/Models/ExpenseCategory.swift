//
//  ExpenseCategory.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 23.06.26.
//

import Foundation
import SwiftData

@Model
final class ExpenseCategory {
    var title: String
    var timestamp: Date
    
    init(title: String, timestamp: Date = .now) {
        self.title = title
        self.timestamp = timestamp
    }
}

extension ExpenseCategory {
    static var initialCategories: [ExpenseCategory] = [
        .init(title: "No Category"),
        .init(title: "Groceries"),
        .init(title: "Housing"),
        .init(title: "Transport"),
        .init(title: "Shopping"),
        .init(title: "Entertainment"),
    ]
}
