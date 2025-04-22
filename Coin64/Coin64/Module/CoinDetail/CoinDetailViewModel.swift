//
//  CoinDetailViewModel.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//
import Foundation

protocol CoinDetailViewDelegate {
    func showError(message: String, retryAction: @escaping () -> Void)
    func hideError()
    func showLoading()
    func hideLoading()
}

protocol CoinDetailViewModelProtocol {
    var viewDeleagte: CoinDetailViewDelegate? { get set }
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
    var viewDeleagte: CoinDetailViewDelegate?


    init(coinRepository: CoinRepositoryProtocol, dateTimeStamp: String, coinInfoResponses: [CoinInfoResponse] = []) {
        self.coinRepository = coinRepository
        self.dateTimeStamp = dateTimeStamp
        self.coinInfoResponses = coinInfoResponses
    }


    func getBTCCurrencies(completion: @escaping ([CoinInfoResponse]) -> Void) {
        isLoading = true
        viewDeleagte?.showLoading()
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
                    DispatchQueue.main.async { [weak self] in
                        self?.viewDeleagte?.showError(message: "Unable to fetch the price.\n\(error.localizedDescription)") {
                            self?.viewDeleagte?.hideLoading()
                            self?.viewDeleagte?.hideError()
                            self?.getBTCCurrencies(completion:completion)
                        }
                    }
                    completion([])
                case .success(let coinDataResponse):
                    if let response = coinDataResponse.coinInfoResponses.first {
                        coinInfoResponses.append(response)
                        if coinInfoResponses.count == currencies.count {
                            isLoading = false
                        }
                    }
                    if !isLoading {
                        DispatchQueue.main.async { [weak self] in
                            self?.viewDeleagte?.hideLoading()
                        }
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

