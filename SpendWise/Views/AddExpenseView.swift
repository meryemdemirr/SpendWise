//
//  AddExpenseView.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    let dataStore: DataStore
    @StateObject private var viewModel: AddExpenseViewModel

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: AddExpenseViewModel(dataStore: dataStore))
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $viewModel.title)

                TextField("Amount", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)

                Picker("Currency", selection: $viewModel.selectedCurrency) {
                    ForEach(Currency.allCases) { currency in
                        Text("\(currency.symbol) \(currency.rawValue)")
                            .tag(currency)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task {
                        let success = await viewModel.saveExpense()
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save Expense")
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Add Expense")
        .dismissKeyboardToolbar()
    }
}

#Preview {
    NavigationStack {
        AddExpenseView(dataStore: DataStore())
    }
}
