//
//  DataStore.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import Foundation
import Combine

private enum StorageKey {
    static let settings = "SpendWise.AppSettings"
    static let expensesFileName = "expenses.json"
}

final class DataStore: ObservableObject {
    @Published private(set) var settings: AppSettings?
    @Published private(set) var expenses: [Expense] = []

    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private var expensesFileURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(StorageKey.expensesFileName)
    }

    init(
        userDefaults: UserDefaults = .standard,
        fileManager: FileManager = .default
    ) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
        loadSettings()
        loadExpenses()
    }


    private func loadSettings() {
        guard let data = userDefaults.data(forKey: StorageKey.settings),
              let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            settings = nil
            return
        }
        settings = decoded
    }

    func saveSettings(_ newSettings: AppSettings) {
        settings = newSettings
        if let data = try? JSONEncoder().encode(newSettings) {
            userDefaults.set(data, forKey: StorageKey.settings)
        }
    }

    func clearSettings() {
        settings = nil
        userDefaults.removeObject(forKey: StorageKey.settings)
    }

    // MARK: - Expenses

    private func loadExpenses() {
        guard fileManager.fileExists(atPath: expensesFileURL.path),
              let data = try? Data(contentsOf: expensesFileURL),
              let decoded = try? JSONDecoder().decode([Expense].self, from: data) else {
            expenses = []
            return
        }
        expenses = decoded.sorted { $0.date > $1.date }
    }

    private func saveExpenses() {
        let data = (try? JSONEncoder().encode(expenses)) ?? Data()
        try? data.write(to: expensesFileURL)
    }

    func addExpense(_ expense: Expense, deductFromBalance: Double) {
        expenses.insert(expense, at: 0)
        if var s = settings {
            s.currentBalance -= deductFromBalance
            settings = s
            saveSettings(s)
        }
        saveExpenses()
    }

    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        if var s = settings {
            s.currentBalance += expense.convertedAmount
            settings = s
            saveSettings(s)
        }
        saveExpenses()
    }

    func updateExpense(_ expense: Expense, previousConvertedAmount: Double, newConvertedAmount: Double) {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        expenses[index] = expense
        if var s = settings {
            s.currentBalance += previousConvertedAmount - newConvertedAmount
            settings = s
            saveSettings(s)
        }
        saveExpenses()
    }

   
    var totalSpending: Double {
        expenses.reduce(0) { $0 + $1.convertedAmount }
    }
}
