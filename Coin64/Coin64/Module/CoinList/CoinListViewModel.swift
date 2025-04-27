//
//  CoinViewModel.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

import Foundation
import Combine

protocol CoinListViewModelProtocol: ObservableObject {
    var sortedCoinDataResponse: [CoinInfoResponse] { get set }
    var isLoading: Bool { get set }
    var isRefreshingEnabled: Bool { get set}
    var errorMessage: String? { get set }
    func getBTCHistory()
    func getLatestBTC()
    func makeCoinDetailViewModel(dateTimeStamp: Int) -> CoinDetailViewModel
    func isLatestItem(dateTimeStamp: Int?) -> Bool
}

class CoinListViewModel: CoinListViewModelProtocol {

    let refreshRateInSeconds: TimeInterval = 10
    let dayLimit: Int = 14
    let defaultCurrency: Currency = .eur
    let defaultInstrumentType: InstrumentType = .btc

    @Published var sortedCoinDataResponse: [CoinInfoResponse] = []
    @Published var isLoading = false
    @Published var isRefreshingEnabled = true
    @Published var errorMessage: String? = nil

    private let coinRepository: CoinRepositoryProtocol
    private let timerService: TimerServiceProtocol

    private var cancellables: Set<AnyCancellable> = []

    init(coinRepository: CoinRepositoryProtocol, timerService: TimerServiceProtocol = TimerService()) {
        self.coinRepository = coinRepository
        self.timerService = timerService
    }

    func getBTCHistory() {
        isLoading = true
        coinRepository
            .fetchHistory(
                instrumentType: defaultInstrumentType,
                dayLimit: dayLimit,
                currency: defaultCurrency,
                dateTimeStamp: nil
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = nil
                }
            } receiveValue: { [weak self] coinDataResponse in
                self?.isLoading = false
                self?.sortedCoinDataResponse = coinDataResponse.coinInfoResponses.sorted { $0.timestamp > $1.timestamp }
                self?.setupRefreshTimer()
            }.store(in: &cancellables)
    }

    func getLatestBTC() {
        coinRepository.fetchCurrent(instrumentType: .btc, currency: .eur)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] coinCurrentDataResponse in
                if var latest = self?.sortedCoinDataResponse.first {
                    latest.updateBy(
                        timestamp: coinCurrentDataResponse.lastTimeStamp,
                        close: coinCurrentDataResponse.currentValue
                    )
                    self?.sortedCoinDataResponse[0] = latest
                }
            }
            .store(in: &cancellables)
    }

    private func setupRefreshTimer() {
        timerService.startTimer(interval: refreshRateInSeconds, repeats: true) { [weak self] in
            guard let self = self, self.isRefreshingEnabled else { return }
            self.getLatestBTC()
        }
    }

    deinit {
        timerService.invalidate()
    }

    func isLatestItem(dateTimeStamp: Int?) -> Bool {
        sortedCoinDataResponse.first?.timestamp == dateTimeStamp
    }
}


// MARK: - CoinListViewModel Factory

extension CoinListViewModel {
    func makeCoinDetailViewModel(dateTimeStamp: Int) -> CoinDetailViewModel {
        return CoinDetailViewModel(coinRepository: coinRepository, dateTimeStamp: String(dateTimeStamp))
    }
}
