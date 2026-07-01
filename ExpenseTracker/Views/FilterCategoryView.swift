//
//  SelectCategoryView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 23.06.26.
//

import SwiftUI
import SwiftData

struct FilterCategoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExpenseCategory.timestamp)
    private var categories: [ExpenseCategory]
    
    @Binding var filterCategory: ExpenseCategory?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        filterCategory = nil
                        dismiss()
                    } label: {
                        HStack {
                            Text("No Filter")
                            Spacer()
                            
                            if(filterCategory == nil) {
                                Image(systemName: "checkmark").foregroundColor(.blue)
                            }
                        }
                    }
                    .tint(.primary)
                }
                
                
                ForEach(categories) { category in
                    Button {
                        filterCategory = category
                        dismiss()
                    } label: {
                        HStack {
                            CategoryIconView(category: category)
                            Text(category.title)
                            Spacer()
                            
                            if(category == filterCategory) {
                                Image(systemName: "checkmark").foregroundColor(.blue)
                            }
                        }
                    }
                    .tint(.primary)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Filter Category")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    @Previewable @State var filterCategory: ExpenseCategory? = ExpenseCategory.noCategory
    
    FilterCategoryView(filterCategory: $filterCategory)
        .applyDependencies()
}
