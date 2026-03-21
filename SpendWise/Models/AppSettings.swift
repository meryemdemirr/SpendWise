//
//  AppSettings.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import Foundation

struct AppSettings: Codable, Equatable {
    var baseCurrencyCode: String
    var initialBalance: Double
    var currentBalance: Double

    init(baseCurrency: Currency, initialBalance: Double) {
        self.baseCurrencyCode = baseCurrency.rawValue
        self.initialBalance = initialBalance
        self.currentBalance = initialBalance
    }

    var baseCurrency: Currency? {
        Currency(rawValue: baseCurrencyCode)
    }
}
