//
//  CurrencyManager.swift
//  ExpenseTracker
//
//  Created by Yannick Wesseloh on 19.06.26.
//

import Foundation
import Combine

@Observable
class CurrencyManager {
    let currencySymbol: String
    private let currencyFormatter: NumberFormatter
    private let decimalFormatter: NumberFormatter
    
    init(locale: Locale = .current) {
        self.currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = locale
        currencySymbol = locale.currencySymbol ?? "€"
        
        self.decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.locale = Locale.current
        decimalFormatter.minimumFractionDigits = currencyFormatter.minimumFractionDigits
        decimalFormatter.maximumFractionDigits = currencyFormatter.maximumFractionDigits
    }
    
    func formatInput(_ input: String) -> String {
        let decimalSeparator = currencyFormatter.decimalSeparator ?? "."
        
        // Allow only digits and one decimal separator
        var filtered = input.filter { $0.isNumber || $0 == Character(decimalSeparator) }

        // Ensure only one decimal point
        let parts = filtered.components(separatedBy: decimalSeparator)
        if parts.count > 2 {
            filtered = parts[0] + decimalSeparator + parts[1...].joined()
        }

        // Limit to 2 digits after the decimal point
        if let dotIndex = filtered.firstIndex(of: Character(decimalSeparator)) {
            let decimals = filtered[filtered.index(after: dotIndex)...]
            if decimals.count > 2 {
                let limitedDecimals = decimals.prefix(2)
                filtered = String(filtered[..<filtered.index(after: dotIndex)]) + limitedDecimals
            }
        }

        return filtered
    }
    
    func decimalPrice(from priceText: String) -> Decimal? {
        return decimalFormatter.number(from: priceText)?.decimalValue
    }
    
    func decimalPrice(from minorUnits: Int) -> Decimal {
        let multiplier = minorUnitMultiplier()
        return Decimal(minorUnits) / Decimal(multiplier)
    }
    
    func minorUnits(from priceText: String) -> Int? {
        guard let decimalPrice = decimalPrice(from: priceText) else { return nil }
        
        let multiplier = minorUnitMultiplier()
        let minorUnits = decimalPrice * Decimal(multiplier)
        return NSDecimalNumber(decimal: minorUnits).intValue
    }
    
    func priceText(from minorUnits: Int) -> String? {
        let decimalPrice = decimalPrice(from: minorUnits)
        return decimalFormatter.string(from: decimalPrice as NSNumber)
    }
    
    private func minorUnitMultiplier() -> Int {
        let fractionDigits = currencyFormatter.maximumFractionDigits
        return Int(pow(10.0, Double(fractionDigits)))
    }
}
