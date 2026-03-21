//
//  SpendWiseApp.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import SwiftUI

@main
struct SpendWiseApp: App {
    @StateObject private var dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dataStore)
        }
    }
}
