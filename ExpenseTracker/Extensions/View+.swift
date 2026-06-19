//
//  View+.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 19.06.26.
//

import Foundation
import SwiftUI

extension View {
    func previewDependencies() -> some View {
        return self.environment(CurrencyManager())
    }
}
