//
//  CoinDetailViewModel.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Updated by Reza on 27.04.25.
//
import Foundation
import Combine

protocol CoinDetailViewModelProtocol: ObservableObject {
    var isLoading: Bool { get set }
    var coinInfoResponses: [CoinInfoResponse] { get set }
    var errorMessage: String? { get set }
    func getBTCCurrencies()
}

class CoinDetailViewModel: CoinDetailViewModelProtocol {
    private let coinRepository: CoinRepositoryProtocol
    private let dateTimeStamp: String
    private let dayLimit = 1
    private let currencies: [Currency] = [.eur, .usd, .gbp]
    private var cancellables: Set<AnyCancellable> = []

    @Published var coinInfoResponses: [CoinInfoResponse]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil


    init(coinRepository: CoinRepositoryProtocol, dateTimeStamp: String, coinInfoResponses: [CoinInfoResponse] = []) {
        self.coinRepository = coinRepository
        self.dateTimeStamp = dateTimeStamp
        self.coinInfoResponses = coinInfoResponses
    }


    func getBTCCurrencies() {
        isLoading = true
        let publishers = currencies.compactMap {
            coinRepository.fetchHistory(
                instrumentType: .btc,
                dayLimit: dayLimit,
                currency: $0,
                dateTimeStamp: dateTimeStamp
            )
        }

        Publishers
            .MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false

                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = nil
                }
            } receiveValue: { [weak self] result in
                self?.coinInfoResponses = result
                    .compactMap { coinDataResponse in
                        coinDataResponse.coinInfoResponses.first
                    }
                    .sorted { $0.instrument < $1.instrument }

            }
            .store(in: &cancellables)
    }
}

