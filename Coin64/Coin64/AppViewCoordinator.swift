//
//  ViewController.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

import UIKit

protocol ViewCoordinator {
    static func assemble() -> UIViewController
}

class AppViewCoordinator: ViewCoordinator {
    static func assemble() -> UIViewController {
        let coinViewController = CoinListViewController()
        let coinRepository = CoinRepository(serviceProvider: CoinServiceProvider())
        coinViewController.coinViewModel = CoinListViewModel(coinRepository: coinRepository)
        coinViewController.coinViewModel?.viewDeleagte = coinViewController
        let navigationContoller = UINavigationController(rootViewController: coinViewController)
        navigationContoller.modalPresentationStyle = .fullScreen
        return navigationContoller
    }
}
