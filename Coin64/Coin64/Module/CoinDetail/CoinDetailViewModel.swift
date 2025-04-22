//
//  CoinDetailViewModel.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//
import Foundation

protocol CoinDetailViewModelProtocol {
    func getBTCCurrencies(completion: @escaping ([CoinInfoResponse]) -> Void)
    func formattedCurrentDate() -> String
}

class CoinDetailViewModel: CoinDetailViewModelProtocol {
    private let coinRepository: CoinRepositoryProtocol
    private let dateTimeStamp: String
    private let dayLimit = 1
    private let currencies: [Currency] = [.eur, .usd, .gbp]
    private var coinInfoResponses: [CoinInfoResponse]
    private var isLoading: Bool = false


    init(coinRepository: CoinRepositoryProtocol, dateTimeStamp: String, coinInfoResponses: [CoinInfoResponse] = []) {
        self.coinRepository = coinRepository
        self.dateTimeStamp = dateTimeStamp
        self.coinInfoResponses = coinInfoResponses
    }


    func getBTCCurrencies(completion: @escaping ([CoinInfoResponse]) -> Void) {
        isLoading = true
        currencies.forEach { currency in
            coinRepository.fetchHistory(
                instrumentType: .btc,
                dayLimit: dayLimit,
                currency: currency,
                dateTimeStamp: dateTimeStamp
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case .failure(let error):
                    // This is simlar to CoinListViewController. For the sake of simplicity, I skipped it. (related to CoinListViewModel.swift comment)
                    print("Error: \(error)")
                    completion([])
                case .success(let coinDataResponse):
                    if let response = coinDataResponse.coinInfoResponses.first {
                        coinInfoResponses.append(response)
                        if coinInfoResponses.count == currencies.count {
                            isLoading = false
                        }
                    }
                    if !isLoading {
                        completion(coinInfoResponses)
                    }
                }
            }
        }
    }

    func formattedCurrentDate() -> String {
        dateTimeStamp.formattedDate
    }
}

