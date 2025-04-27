//
//  AppDelegate.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Updated by Reza on 27.04.25.
//

import SwiftUI
import Combine

@main
struct Coin64App: App {
    var body: some Scene {
        WindowGroup {
            let serviceProvider = CoinServiceProvider()
            let repository = CoinRepository(serviceProvider: serviceProvider)
            let viewModel = CoinListViewModel(coinRepository: repository)
            CoinListView(viewModel: viewModel)
        }
    }
}
