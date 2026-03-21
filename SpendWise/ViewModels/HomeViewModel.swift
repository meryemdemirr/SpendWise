//
//  HomeViewModel.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isLoadingRates: Bool = false
    @Published var errorMessage: String?

    private let dataStore: DataStore
    private let currencyService: CurrencyServiceProtocol

    init(dataStore: DataStore, currencyService: CurrencyServiceProtocol = CurrencyService()) {
        self.dataStore = dataStore
        self.currencyService = currencyService
    }

    var settings: AppSettings? {
        dataStore.settings
    }

    var expenses: [Expense] {
        dataStore.expenses
    }

    var totalSpending: Double {
        dataStore.totalSpending
    }

    func reloadRates() async {
        guard let base = dataStore.settings?.baseCurrency else { return }
        isLoadingRates = true
        errorMessage = nil

        do {
            _ = try await currencyService.fetchRates(base: base)
            // Optionally cache and use for display; balance is already stored in base currency.
        } catch {
            errorMessage = "Failed to fetch latest rates."
        }

        isLoadingRates = false
    }

    func deleteExpense(_ expense: Expense) {
        dataStore.deleteExpense(expense)
    }
}
