//
//  Currency.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import Foundation

enum Currency: String, CaseIterable, Codable, Identifiable {
    case tryCurrency = "TRY"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .tryCurrency: return "₺"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        }
    }
}
