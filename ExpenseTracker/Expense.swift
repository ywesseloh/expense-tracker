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
