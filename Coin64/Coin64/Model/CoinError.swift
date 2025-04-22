//
//  CoinError.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

struct CoinErrorOther: Decodable {
    let param: String
    let values: [String]
}
struct CoinError: Decodable {
    let type: Int?
    let message: String?
    let otherInfo: CoinErrorOther?

    enum CodingKeys: String, CodingKey {
        case type
        case message
        case otherInfo = "other_info"
    }
}
