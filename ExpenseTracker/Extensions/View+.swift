//
//  View+.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 19.06.26.
//

import Foundation
import SwiftUI
import SwiftData

extension View {
    func applyDependencies(_ dependencies: AppDependencies = .init(isPreview: true), expenseSamples: [Expense] = []) -> some View {
        for expense in expenseSamples {
            dependencies.modelContainer.mainContext.insert(expense)
        }
        
        return self
            .modelContainer(dependencies.modelContainer)
            .environment(dependencies.currencyManager)
    }
}

extension Scene {
    func applyDependencies(_ dependencies: AppDependencies) -> some Scene {
        return self
            .modelContainer(dependencies.modelContainer)
            .environment(dependencies.currencyManager)
    }
}
