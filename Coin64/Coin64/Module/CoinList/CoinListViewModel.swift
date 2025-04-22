//
//  CoinViewModel.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

import Foundation

protocol CoinListViewDelegate {
    func showError(message: String)
    func hideError()
}

protocol CoinListViewModelProtocol {
    var viewDeleagte: CoinListViewDelegate? { get set }
    var sortedCoinDataResponse: [CoinInfoResponse] { get }
    func getBTCHistory(completion: @escaping ([CoinInfoResponse]) -> Void)
    func getLatestBTC(completion: @escaping () -> Void)
    func setRefreshLastPrice(isEnable: Bool, completion: @escaping () -> Void)
    func showDetail(index:Int, completion: ((CoinDetailViewModel) -> Void))
}

class CoinListViewModel: CoinListViewModelProtocol {
    private let coinRepository: CoinRepositoryProtocol
    let refreshRateInSeconds: TimeInterval = 60

    private var timer: Timer?
    var viewDeleagte: CoinListViewDelegate?
    var sortedCoinDataResponse: [CoinInfoResponse] = []

    init(coinRepository: CoinRepositoryProtocol) {
        self.coinRepository = coinRepository
    }

    func getBTCHistory(completion: @escaping ([CoinInfoResponse]) -> Void) {
        coinRepository
            .fetchHistory(
                instrumentType: .btc,
                dayLimit: 14,
                currency: .eur,
                dateTimeStamp: nil
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(_):
                    DispatchQueue.main.async { [weak self] in
                        self?.viewDeleagte?.showError(message: "There was an error fetching data from the server.")
                    }
                    completion([])
                case .success(let coinDataResponse):
                    sortedCoinDataResponse = coinDataResponse.coinInfoResponses.sorted { $0.timestamp > $1.timestamp }
                    completion(sortedCoinDataResponse)
                }

            }
    }

    func getLatestBTC(completion: @escaping () -> Void) {
        coinRepository.fetchCurrent(instrumentType: .btc, currency: .eur, completeion: { [weak self] result in
            guard let self = self else { return }
            // Update with latest price and date
            switch result {
            case .failure(let error):
                //Note: This can be managed like getBTCHistory, but for keep it small I skip it. (please check CoinDetailViewModel.swift comment)
                completion()
            case .success(let coinDataResponse):
                if !sortedCoinDataResponse.isEmpty {
                    sortedCoinDataResponse[0].close = coinDataResponse.currentValue
                    sortedCoinDataResponse[0].timestamp = coinDataResponse.lastTimeStamp
                }
                completion()
            }

        })
    }

    func showDetail(index: Int, completion: (CoinDetailViewModel) -> Void) {
        let coinDetailViewModel = CoinDetailViewModel(
            coinRepository: coinRepository,
            dateTimeStamp: "\(sortedCoinDataResponse[index].timestamp)"
        )
        completion(coinDetailViewModel)
    }
}

// - MARK: Refreshing the price
extension CoinListViewModel {

    func setRefreshLastPrice(isEnable: Bool, completion: @escaping () -> Void) {
        if isEnable {
            startTimer(completion: completion)
        } else {
            stopTimer()
        }
    }

    private func startTimer(completion: @escaping () -> Void) {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: refreshRateInSeconds, repeats: true) { [weak self] _ in
            self?.getLatestBTC(completion: completion)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
