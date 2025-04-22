//
//  CoinData.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

struct CoinData: Decodable {
    let data: [CoinInfo]
    let error: CoinError?

    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case error = "Err"
    }
}

