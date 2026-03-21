//
//  AddExpenseViewModel.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import Foundation
import Combine

@MainActor
final class AddExpenseViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var amountText: String = ""
    @Published var selectedCurrency: Currency = .tryCurrency
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let dataStore: DataStore
    private let currencyService: CurrencyServiceProtocol
    private var ratesCache: [String: Double] = [:]

    var baseCurrency: Currency? {
        dataStore.settings?.baseCurrency
    }

    init(dataStore: DataStore, currencyService: CurrencyServiceProtocol = CurrencyService()) {
        self.dataStore = dataStore
        self.currencyService = currencyService
    }

    func loadRatesIfNeeded() async {
        guard let base = baseCurrency else { return }
        if !ratesCache.isEmpty { return }

        do {
            let rates = try await currencyService.fetchRates(base: base)
            ratesCache = rates
        } catch {
            errorMessage = "Failed to load exchange rates."
        }
    }

    /// Converts amount from selected currency to base currency using cached rates.
    /// - Returns: Converted amount in base currency, or nil if conversion not possible.
    private func convertToBase(amount: Double) -> Double? {
        guard let base = baseCurrency else { return nil }
        if selectedCurrency == base {
            return amount
        }
        guard let rate = ratesCache[selectedCurrency.rawValue], rate > 0 else {
            return nil
        }
        // API rates: 1 base = rate of other. So otherAmount / rate = baseAmount.
        return amount / rate
    }

    func saveExpense() async -> Bool {
        guard let baseCurrency = baseCurrency else {
            errorMessage = "Base currency not set."
            return false
        }

        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a title."
            return false
        }

        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              amount > 0 else {
            errorMessage = "Please enter a valid amount."
            return false
        }

        isSaving = true
        errorMessage = nil

        await loadRatesIfNeeded()

        guard let convertedAmount = convertToBase(amount: amount) else {
            errorMessage = "No exchange rate available for \(selectedCurrency.rawValue)."
            isSaving = false
            return false
        }

        guard let currentBalance = dataStore.settings?.currentBalance,
              convertedAmount <= currentBalance else {
            errorMessage = "Insufficient balance."
            isSaving = false
            return false
        }

        let expense = Expense(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount,
            expenseCurrency: selectedCurrency,
            convertedAmount: convertedAmount
        )

        dataStore.addExpense(expense, deductFromBalance: convertedAmount)

        isSaving = false
        return true
    }
}
