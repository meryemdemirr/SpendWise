//
//  UpdateBalanceViewModel.swift
//  SpendWise
//
//  PLACE: ViewModels folder — logic and state for updating the CoreBalance later.
//

import Foundation
import Combine

@MainActor
final class UpdateBalanceViewModel: ObservableObject {
    enum OperationType: String, CaseIterable, Identifiable {
        case add
        case subtract
        case set

        var id: String { rawValue }

        var title: String {
            switch self {
            case .add: return "Add"
            case .subtract: return "Subtract"
            case .set: return "Set"
            }
        }
    }

    @Published var amountText: String = ""
    @Published var operation: OperationType = .add
    @Published var isApplying: Bool = false
    @Published var errorMessage: String?

    @Published private(set) var currentBalance: Double?

    private let dataStore: DataStore
    private var cancellables = Set<AnyCancellable>()

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        observeDataStore()
    }

    private func observeDataStore() {
        currentBalance = dataStore.settings?.currentBalance
        dataStore.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                self?.currentBalance = settings?.currentBalance
            }
            .store(in: &cancellables)
    }

    var baseCurrency: Currency? {
        dataStore.settings?.baseCurrency
    }

    func applyUpdate() async -> Bool {
        errorMessage = nil

        guard let rawAmount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              rawAmount > 0 else {
            errorMessage = "Enter a valid amount greater than 0."
            return false
        }

        guard var settings = dataStore.settings else {
            errorMessage = "Base settings not found."
            return false
        }

        let current = settings.currentBalance
        let newBalance: Double

        switch operation {
        case .add:
            newBalance = current + rawAmount
        case .subtract:
            newBalance = current - rawAmount
        case .set:
            newBalance = rawAmount
        }

        // Prevent negative balances for Add/Subtract. (Set is safe because amount > 0.)
        if newBalance < 0 {
            errorMessage = "Insufficient balance."
            return false
        }

        isApplying = true
        settings.currentBalance = newBalance
        dataStore.saveSettings(settings)
        isApplying = false

        // Clear input after success for nicer UX if user reopens the sheet.
        amountText = ""
        operation = .add

        return true
    }
}

