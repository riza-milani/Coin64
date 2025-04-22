//
//  Untitled.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//
import XCTest
@testable import Coin64

class MockRepository: CoinRepositoryProtocol {
    var shouldRaiseError: Bool = false

    func fetchCurrent(instrumentType: Coin64.InstrumentType, currency: Coin64.Currency, completeion: @escaping (Result<Coin64.CoinCurrentResponse, any Error>) -> Void) {
        switch shouldRaiseError {
        case true:
            completeion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            return
        default:
            completeion(.success(Coin64.CoinCurrentResponse(currentValue: 2000, lastTimeStamp: 1744156801)))
        }
    }

    func fetchHistory(instrumentType: Coin64.InstrumentType, dayLimit: Int, currency: Coin64.Currency, dateTimeStamp: String?, completeion: @escaping (Result<Coin64.CoinDataResponse, any Error>) -> Void) {
        switch shouldRaiseError {
        case true:
            completeion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            return
        default:
            let coinInfo = CoinInfo(timestamp: 1744156800, type: "986", market: "cadli", instrument: "BTC-EUR", open: 1000.0, high: 1000.0, low: 800.0, close: 1000.0)
            let coinData = CoinData(data: [coinInfo], error: nil)
            let response = CoinDataResponse(coinData: coinData)
            completeion(.success(response))
        }

    }


}
