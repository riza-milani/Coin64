//
//  CoinRepository.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Updated by Reza on 27.04.25.
//

import Combine

protocol CoinRepositoryProtocol {
    func fetchCurrent(
        instrumentType: InstrumentType,
        currency: Currency
    ) -> AnyPublisher<CoinCurrentResponse, Error>

    func fetchHistory(
        instrumentType: InstrumentType,
        dayLimit: Int,
        currency: Currency,
        dateTimeStamp: String?
    ) -> AnyPublisher<CoinDataResponse, Error>
}

class CoinRepository: CoinRepositoryProtocol {

    private let serviceProvider: CoinServiceProviderProtocol

    init(serviceProvider: CoinServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }
    /// Fetches current exchange rate of BTC
    /// currency: default value is set to EUR, regarding the task requirements.
    func fetchCurrent(
        instrumentType: InstrumentType,
        currency: Currency = .eur
    ) -> AnyPublisher<CoinCurrentResponse, Error> {
        let endpoint: Endpoint = .current(.production, instrumentType, currency)
        return serviceProvider.request(endpoint, responseType: CoinCurrentData.self)
            .map {
                CoinCurrentResponse(
                    currentValue: $0.exchange.currentValue,
                    lastTimeStamp: $0.exchange.lastTimeStamp
                )
            }
            .eraseToAnyPublisher()
    }

    /// Fetches historical exchange rates of BTC
    /// dayLimit: default value is set to 14 days, regarding the task requirements.
    /// currency: default value is set to EURO, regarding the task requirements.
    func fetchHistory(
        instrumentType: InstrumentType = .btc,
        dayLimit: Int = 14,
        currency: Currency = .eur,
        dateTimeStamp: String? = nil
    ) -> AnyPublisher<CoinDataResponse, Error> {
        let endpoint: Endpoint = .historical(
            .production,
            instrumentType,
            currency,
            daysLimit: dayLimit,
            dateTimeStamp: dateTimeStamp
        )
        return serviceProvider.request(endpoint, responseType: CoinData.self)
            .map { CoinDataResponse(coinData: $0) }
            .eraseToAnyPublisher()
    }
}
