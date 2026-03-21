//
//  ExpenseRowView.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    let baseCurrency: Currency?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)

                Text("\(expense.amount, specifier: "%.2f") \(expense.expenseCurrencyCode)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let base = baseCurrency {
                Text("\(base.symbol) \(expense.convertedAmount, specifier: "%.2f")")
                    .font(.headline)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    List {
        ExpenseRowView(
            expense: Expense(
                title: "Coffee",
                amount: 5,
                expenseCurrency: .usd,
                convertedAmount: 150,
                date: Date()
            ),
            baseCurrency: .tryCurrency
        )
    }
}
