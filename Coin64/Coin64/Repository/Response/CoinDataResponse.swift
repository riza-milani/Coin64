//
//  CoinRateResponse.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

struct CoinInfoResponse: Decodable {
    var timestamp: Int
    let type: String
    let market: String
    let instrument: String
    let open: Double
    let high: Double
    let low: Double
    var close: Double
}

extension CoinInfoResponse {
    var currencySymbol: String {
        switch instrument {
        case "BTC-EUR":
            return "€"
        case "BTC-USD":
            return "$"
        case "BTC-GBP":
            return "£"
        default:
            return ""
        }
    }
}


struct CoinDataResponse: Decodable {
    private let coinData: CoinData
    init(coinData: CoinData) {
        self.coinData = coinData
    }
    var coinInfoResponses: [CoinInfoResponse] {
        get {
            coinData.data.map { info in
                CoinInfoResponse(timestamp: info.timestamp,
                                 type: info.type,
                                 market: info.market,
                                 instrument: info.instrument,
                                 open: info.open,
                                 high: info.high,
                                 low: info.low,
                                 close: info.close)
            }
        }
    }
}
