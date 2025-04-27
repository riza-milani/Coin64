//
//  CoinDetailView.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Updated by Reza on 27.04.25.
//

import SwiftUI

struct CoinDetailView<ViewModel>: View where ViewModel: CoinDetailViewModelProtocol  {
    @StateObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if viewModel.errorMessage != nil {
                ErrorView(message: viewModel.errorMessage ?? "Unknown error") {
                    viewModel.getBTCCurrencies()
                }
            } else {
                VStack(spacing: 24) {
                    List {
                        ForEach(viewModel.coinInfoResponses, id: \.instrument) { item in
                            CoinDetailCardView(price: item)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color.red.opacity(0.08))
            }
        }
        .navigationTitle("Price Detail")
        .onAppear() {
            viewModel.getBTCCurrencies()
        }
    }
}
