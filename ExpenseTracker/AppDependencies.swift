//
//  AppDependencies.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 23.06.26.
//

import Foundation
import SwiftData

class AppDependencies {
    let modelContainer: ModelContainer
    let currencyManager: CurrencyManager
    
    init(isPreview: Bool = false) {
        do {
            // Create Model Containter
            let schema = Schema([
                Expense.self,
                ExpenseCategory.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isPreview)
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Add initial expense categories if not already stored
            let context = modelContainer.mainContext
            var fetchDescriptor = FetchDescriptor<ExpenseCategory>()
            fetchDescriptor.fetchLimit = 1
            let existingCategories = try context.fetch(fetchDescriptor)
            
            if existingCategories.isEmpty {
                for category in ExpenseCategory.initialCategories {
                    context.insert(category)
                }
                try context.save()
            }
            
            self.modelContainer = modelContainer
            self.currencyManager = CurrencyManager()
            
        } catch {
            fatalError("Could not initialize AppDependencies: \(error)")
        }
    }
}
