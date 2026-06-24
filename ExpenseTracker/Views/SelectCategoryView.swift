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
    @Query(sort: \ExpenseCategory.timestamp)
    private var categories: [ExpenseCategory]
    
    @Binding var selectedCategory: ExpenseCategory?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button {
                        selectedCategory = category
                        dismiss()
                    } label: {
                        HStack {
                            Text(category.title)
                            Spacer()
                            
                            if(category == selectedCategory) {
                                Image(systemName: "checkmark").foregroundColor(.blue)
                            }
                        }
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle("Select Category")
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory: ExpenseCategory?
    
    SelectCategoryView(selectedCategory: $selectedCategory)
        .applyDependencies()
}
