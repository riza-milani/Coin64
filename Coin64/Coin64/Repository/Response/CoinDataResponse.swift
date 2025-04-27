//
//  CoinRateResponse.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Created by Reza on 27.04.25.
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

    var increasingPrice: Bool {
        close >= `open`
    }

    var change: Double {
        abs(close - `open`)
    }

    var changePercent: Double {
        (change / `open`) * 100
    }

    mutating func updateBy(timestamp: Int ,close: Double) {
        self.close = close
        self.timestamp = timestamp
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

extension CoinInfoResponse: Equatable {
    static func == (lhs: CoinInfoResponse, rhs: CoinInfoResponse) -> Bool {
        return lhs.timestamp == rhs.timestamp &&
               lhs.instrument == rhs.instrument &&
               lhs.close == rhs.close &&
               lhs.open == lhs.open &&
               lhs.high == lhs.high &&
               lhs.low == lhs.low
    }
}
