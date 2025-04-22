//
//  CoinRepository.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

protocol CoinRepositoryProtocol {
    func fetchCurrent(
        instrumentType: InstrumentType,
        currency: Currency,
        completeion: @escaping (Result<CoinCurrentResponse,Error>) -> Void
    )
    func fetchHistory(
        instrumentType: InstrumentType,
        dayLimit: Int,
        currency: Currency,
        dateTimeStamp: String?,
        completeion: @escaping (Result<CoinDataResponse,Error>) -> Void
    )
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
        currency: Currency = .eur,
        completeion: @escaping (Result<CoinCurrentResponse,Error>) -> Void
    ) {
        let endpoint: Endpoint = .current(.production, instrumentType, currency)

        serviceProvider.request(endpoint, responseType: CoinCurrentData.self) { result in
            switch result {
            case .success(let coinCurrentData):
                let response = CoinCurrentResponse(
                    currentValue: coinCurrentData.exchange.currentValue,
                    lastTimeStamp: coinCurrentData.exchange.lastTimeStamp
                )
                completeion(.success(response))

            case .failure(let error):
                completeion(.failure(error))
            }
        }
    }

    /// Fetches historical exchange rates of BTC
    /// dayLimit: default value is set to 14 days, regarding the task requirements.
    /// currency: default value is set to EURO, regarding the task requirements.
    func fetchHistory(
        instrumentType: InstrumentType = .btc,
        dayLimit: Int = 14,
        currency: Currency = .eur,
        dateTimeStamp: String? = nil,
        completeion: @escaping (Result<CoinDataResponse,Error>) -> Void) {
            let endpoint: Endpoint = .historical(
                .production,
                instrumentType,
                currency,
                daysLimit: dayLimit,
                dateTimeStamp: dateTimeStamp
            )

            serviceProvider.request(endpoint, responseType: CoinData.self) { result in
                switch result {
                case .success(let coinData):
                    let response = CoinDataResponse(coinData: coinData)
                    completeion(.success(response))

                case .failure(let error):
                    completeion(.failure(error))
                }
            }
        }
}
