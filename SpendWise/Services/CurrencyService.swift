//
//  CurrencyService.swift
//  SpendWise
//
//  Created by Meryem Demir on 18.03.2026.
//

import Foundation

protocol CurrencyServiceProtocol {
    func fetchRates(base: Currency) async throws -> [String: Double]
}

final class CurrencyService: CurrencyServiceProtocol {
    private let session: URLSession
    private let baseURL = URL(string: "https://open.er-api.com/v6/latest/")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    private struct RatesResponse: Decodable {
        let result: String
        let base_code: String
        let rates: [String: Double]
    }

    func fetchRates(base: Currency) async throws -> [String: Double] {
        let url = baseURL.appendingPathComponent(base.rawValue)
        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
        guard decoded.result == "success" else {
            throw URLError(.cannotParseResponse)
        }

        return decoded.rates
    }
}
