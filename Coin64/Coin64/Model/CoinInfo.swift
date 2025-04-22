//
//  CoinRate.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

struct CoinInfo: Decodable {
    let timestamp: Int
    let type: String
    let market: String
    let instrument: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double

    enum CodingKeys: String, CodingKey {
        case timestamp = "TIMESTAMP"
        case type = "TYPE"
        case market = "MARKET"
        case instrument = "INSTRUMENT"
        case open = "OPEN"
        case high = "HIGH"
        case low = "LOW"
        case close = "CLOSE"
    }
}
