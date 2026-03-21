//
//  Expense.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import Foundation

struct Expense: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var amount: Double
    var expenseCurrencyCode: String
    var convertedAmount: Double
    var date: Date

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        expenseCurrency: Currency,
        convertedAmount: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.expenseCurrencyCode = expenseCurrency.rawValue
        self.convertedAmount = convertedAmount
        self.date = date
    }

    var expenseCurrency: Currency? {
        Currency(rawValue: expenseCurrencyCode)
    }
}
