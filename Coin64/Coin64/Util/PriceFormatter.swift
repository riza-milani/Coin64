//
//  PriceFormatter.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import Foundation

class PriceFormatter {
    static let shared = PriceFormatter()

    private var currencyFormatters: [String: NumberFormatter] = [:]

    private init() {}

    func currencyFormatter(with symbol: String) -> NumberFormatter {
        if let formatter = currencyFormatters[symbol] {
            return formatter
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        currencyFormatters[symbol] = formatter

        return formatter
    }
}
