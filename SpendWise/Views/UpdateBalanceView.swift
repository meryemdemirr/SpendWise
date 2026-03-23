//
//  UpdateBalanceView.swift
//  SpendWise
//
//  PLACE: Views folder — SwiftUI view for updating the CoreBalance later.
//

import SwiftUI

struct UpdateBalanceView: View {
    @Environment(\.dismiss) private var dismiss

    let dataStore: DataStore
    @StateObject private var viewModel: UpdateBalanceViewModel

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: UpdateBalanceViewModel(dataStore: dataStore))
    }

    var body: some View {
        Form {
            Section("Current Balance") {
                if let current = viewModel.currentBalance,
                   let symbol = viewModel.baseCurrency?.symbol {
                    Text("\(symbol) \(current, specifier: "%.2f")")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ProgressView()
                }
            }

            Section("Update") {
                Picker("Operation", selection: $viewModel.operation) {
                    ForEach(UpdateBalanceViewModel.OperationType.allCases) { op in
                        Text(op.title).tag(op)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Amount", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
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
                        let success = await viewModel.applyUpdate()
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isApplying {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Apply Update")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isApplying)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Update Balance")
        .dismissKeyboardToolbar()
    }
}

#Preview {
    NavigationStack {
        UpdateBalanceView(dataStore: {
            let store = DataStore()
            store.saveSettings(AppSettings(baseCurrency: .tryCurrency, initialBalance: 1200))
            return store
        }())
    }
}

