//
//  SelectCategoryView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 23.06.26.
//

import SwiftUI
import SwiftData

struct SelectCategoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Query//(sort: \ExpenseCategory.id)
    private var categories: [ExpenseCategory]
    
    @Binding var selectedCategory: ExpenseCategory?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }, label: {
                        HStack {
                            Text(category.title)
                            Spacer()
                            
                            if(category == selectedCategory) {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                    })
                    
//                    Button(category.title) {
//                        selectedCategory = category
//                        dismiss()
//                    }
                }
            }
            .navigationTitle("Select Category")
        }
    }
}

#Preview {
    SelectCategoryView(selectedCategory: .constant(nil))
        .applyDependencies()
}
