//
//  MainBalanceSetupView.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import SwiftUI

struct MainBalanceSetupView: View {
    let dataStore: DataStore
    @StateObject private var viewModel: MainBalanceViewModel

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: MainBalanceViewModel(dataStore: dataStore))
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to SpendWise")
                .font(.title.bold())

            VStack(alignment: .leading, spacing: 12) {
                Text("Initial Balance")
                    .font(.headline)
                TextField("0.00", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Base Currency")
                    .font(.headline)
                Picker("Currency", selection: $viewModel.selectedCurrency) {
                    ForEach(Currency.allCases) { currency in
                        Text("\(currency.symbol) \(currency.rawValue)")
                            .tag(currency)
                    }
                }
                .pickerStyle(.segmented)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button {
                viewModel.saveInitialSettings()
            } label: {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Continue")
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .disabled(viewModel.isSaving)

            Spacer()
        }
        .padding()
        .dismissKeyboardToolbar()
    }
}

#Preview {
    MainBalanceSetupView(dataStore: DataStore())
}
