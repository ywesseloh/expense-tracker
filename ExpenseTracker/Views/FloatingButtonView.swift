//
//  FloatingButtonView.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 25.06.26.
//

import SwiftUI

struct FloatingButtonView: View {
    var backgroundColor: Color
    var foregroundColor: Color
    var imageName: String
    
    var body: some View {
        Image(systemName: imageName)
            .font(.title.weight(.semibold))
            .padding()
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(Circle())
            .shadow(radius: 4, x: 0, y: 4)
    }
}

#Preview {
    FloatingButtonView(backgroundColor: .pink, foregroundColor: .white, imageName: "plus")
}
