//
//  CoinListView.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Updated by Reza on 27.04.25.
//

import SwiftUI


struct CoinListView<ViewModel>: View where ViewModel: CoinListViewModelProtocol  {
    private let navigationTitle = "Bitcoin Prices"

    @ObservedObject var viewModel: ViewModel
    @State private var isDetailPresented = false
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.errorMessage != nil {
                    ErrorView(message: viewModel.errorMessage ?? "Unknown error") {
                        viewModel.getBTCHistory()
                    }
                } else {
                    List {
                        ForEach(viewModel.sortedCoinDataResponse, id: \.timestamp) { coinDataResponse in

                            NavigationLink(destination: {
                                LazyView(
                                    CoinDetailView(viewModel: viewModel.makeCoinDetailViewModel(dateTimeStamp: coinDataResponse.timestamp))
                                        .id(coinDataResponse.timestamp)
                                        .onAppear() {
                                            viewModel.isRefreshingEnabled = false
                                        }
                                        .onDisappear {
                                            viewModel.isRefreshingEnabled = true
                                        }
                                )

                            }) {
                                CoinListRowView(
                                    coinInfoResponse: coinDataResponse,
                                    isLatest: viewModel.isLatestItem(dateTimeStamp: coinDataResponse.timestamp)
                                )
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .onDisappear() {
                viewModel.isRefreshingEnabled = false
            }
            .navigationTitle(navigationTitle)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.isRefreshingEnabled = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            viewModel.isRefreshingEnabled = true
            viewModel.getBTCHistory()
        }
    }
}
