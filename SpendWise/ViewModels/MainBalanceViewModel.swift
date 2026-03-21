//
//  MainBalanceViewModel.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import Foundation
import Combine

@MainActor
final class MainBalanceViewModel: ObservableObject {
    @Published var amountText: String = ""
    @Published var selectedCurrency: Currency = .tryCurrency
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let dataStore: DataStore

    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }

    func saveInitialSettings() {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              amount >= 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        isSaving = true
        errorMessage = nil

        let newSettings = AppSettings(baseCurrency: selectedCurrency, initialBalance: amount)
        dataStore.saveSettings(newSettings)

        isSaving = false
    }
}
