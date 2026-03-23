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
    private var cancellables = Set<AnyCancellable>()

    // Published copies so the UI reacts to DataStore changes.
    @Published private(set) var settings: AppSettings?
    @Published private(set) var expenses: [Expense] = []
    @Published private(set) var totalSpending: Double = 0

    init(dataStore: DataStore, currencyService: CurrencyServiceProtocol = CurrencyService()) {
        self.dataStore = dataStore
        self.currencyService = currencyService
        bindToDataStore()
    }

    private func bindToDataStore() {
        // Initial snapshot
        self.settings = dataStore.settings
        self.expenses = dataStore.expenses
        self.totalSpending = dataStore.expenses.reduce(0) { $0 + $1.convertedAmount }

        // React to changes
        dataStore.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSettings in
                self?.settings = newSettings
            }
            .store(in: &cancellables)

        dataStore.$expenses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newExpenses in
                self?.expenses = newExpenses
                self?.totalSpending = newExpenses.reduce(0) { $0 + $1.convertedAmount }
            }
            .store(in: &cancellables)
    }

    func reloadRates() async {
        guard let base = settings?.baseCurrency else { return }
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
