//
//  CoinLastData.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//

import Foundation

struct ExchangeData: Decodable {
    let pair: String
    let currentValue: Double
    let lastTimeStamp: Int

    private enum CodingKeys: String, CodingKey {
        case currentValue = "VALUE"
        case lastTimeStamp = "VALUE_LAST_UPDATE_TS"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)

        guard let firstKey = container.allKeys.first else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected at least one key in the container."
            )
            throw DecodingError.dataCorrupted(context)
        }

        pair = firstKey.stringValue
        let nestedContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: firstKey)
        currentValue = try nestedContainer.decode(Double.self, forKey: .currentValue)
        lastTimeStamp = try nestedContainer.decode(Int.self, forKey: .lastTimeStamp)
    }

    struct DynamicKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }

        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
}

struct CoinCurrentData: Decodable {
    let exchange: ExchangeData

    private enum CodingKeys: String, CodingKey {
        case data = "Data"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        exchange = try container.decode(ExchangeData.self, forKey: .data)
    }
}
