//
//  RootView.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        NavigationStack {
            if dataStore.settings != nil {
                HomeView(dataStore: dataStore)
            } else {
                MainBalanceSetupView(dataStore: dataStore)
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(DataStore())
}
