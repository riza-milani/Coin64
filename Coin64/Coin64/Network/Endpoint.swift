//
//  Endpoint.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Updated by Reza on 27.04.25.
//

import Foundation

enum BaseURL: String {
    case production = "https://data-api.coindesk.com/index/cc/v1"
}

protocol EndpointProtocol {
    var url: URL? { get }
    var httpMethod: String { get }
}

enum Endpoint: EndpointProtocol {
    case current(BaseURL, InstrumentType, Currency = .eur)
    case historical(BaseURL, InstrumentType, Currency, daysLimit: Int, dateTimeStamp:String?)

    var url: URL? {
        switch self {
        case .current(let baseURL, let InstrumentType, let currency):
            let instrument = "\(InstrumentType.rawValue)-\(currency.rawValue)"
            return URL(string: "\(baseURL.rawValue)/latest/tick?market=cadli&instruments=\(instrument)&apply_mapping=true")

        case .historical(let baseURL, let InstrumentType, let currency, let dayLimit, let date):
            let instrument = "\(InstrumentType.rawValue)-\(currency.rawValue)"
            var dateString: String = ""
            if let date {
                dateString = "&to_ts=\(String(describing: (date)))"
            }

            return URL(string: "\(baseURL.rawValue)/historical/days?market=cadli&instrument=\(instrument)&limit=\(dayLimit)&aggregate=1&fill=true&apply_mapping=true&response_format=JSON\(dateString)")
        }
    }

    var httpMethod: String {
        switch self {
        default:
            "GET"
        }
    }
}
