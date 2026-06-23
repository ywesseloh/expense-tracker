//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 18.06.26.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    @State private var dependencies = AppDependencies(isPreview: false)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .applyDependencies(dependencies)
    }
}
