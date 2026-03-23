//
//  HomeView.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import SwiftUI

struct HomeView: View {
    let dataStore: DataStore
    @StateObject private var viewModel: HomeViewModel
    @State private var isShowingUpdateBalance = false

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: HomeViewModel(dataStore: dataStore))
    }

    var body: some View {
        VStack(spacing: 16) {
            if let settings = viewModel.settings,
               let base = settings.baseCurrency {
                VStack(spacing: 8) {
                    Text("Current Balance")
                        .font(.headline)
                    Text("\(base.symbol) \(settings.currentBalance, specifier: "%.2f")")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.default, value: settings.currentBalance)

                    Text("Total Spending: \(base.symbol) \(viewModel.totalSpending, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.thinMaterial)
                )
                .padding(.horizontal)
            }

            Button {
                isShowingUpdateBalance = true
            } label: {
                Label("Update Balance", systemImage: "arrow.triangle.2.circlepath")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            HStack {
                Text("Expenses")
                    .font(.headline)
                Spacer()
                if viewModel.isLoadingRates {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Button {
                    Task { await viewModel.reloadRates() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }

            List {
                ForEach(viewModel.expenses) { expense in
                    ExpenseRowView(
                        expense: expense,
                        baseCurrency: viewModel.settings?.baseCurrency
                    )
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let expense = viewModel.expenses[index]
                        viewModel.deleteExpense(expense)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("SpendWise")
        .toolbar {
            NavigationLink {
                AddExpenseView(dataStore: dataStore)
            } label: {
                Image(systemName: "plus.circle.fill")
            }
        }
        .sheet(isPresented: $isShowingUpdateBalance) {
            UpdateBalanceView(dataStore: dataStore)
        }
    }
}

#Preview {
    let store = DataStore()
    store.saveSettings(AppSettings(baseCurrency: .tryCurrency, initialBalance: 1000))
    return NavigationStack {
        HomeView(dataStore: store)
    }
}
