//
//  CategoryIconView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 25.06.26.
//

import SwiftUI

struct CategoryIconView: View {
    let category: ExpenseCategory
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: category.colorHex))
                .frame(width: 30, height: 30)
            Image(systemName: category.iconIdentifier)
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    VStack {
        ForEach(ExpenseCategory.initialCategories) { category in
            CategoryIconView(category: category)
        }
    }
}
