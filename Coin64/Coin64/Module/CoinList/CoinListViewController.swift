//
//  CoinViewController.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

import UIKit

class CoinListViewController: UIViewController {

    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    var coinViewModel: CoinListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.viewControllerTitle
        view.backgroundColor = .systemBackground
        setupTableView()
        
        coinViewModel?.getBTCHistory { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshTableView(isEnabled: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        refreshTableView(isEnabled: false)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CoinListViewCell.self, forCellReuseIdentifier: String(describing: CoinListViewCell.self))
        tableView.backgroundView = activityIndicator

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func refreshTableView(isEnabled: Bool) {
        if isEnabled {
            coinViewModel?.setRefreshLastPrice(isEnable: true) {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                }
            }
        }
        else {
            coinViewModel?.setRefreshLastPrice(isEnable: false) { }
        }
    }
}

// - MARK: Error Handling and Loading Indicator

extension CoinListViewController: CoinListViewDelegate {
    func showError(message: String, retryAction: @escaping () -> Void) {
        tableView.isHidden = true
        refreshTableView(isEnabled: false)
        createErrorView(message: message, retryAction: retryAction)
        hideLoading()
    }

    func hideError() {
        tableView.isHidden = false
        refreshTableView(isEnabled: true)
        removeErrorView()
    }

    func showLoading() {
        activityIndicator.startAnimating()
        tableView.backgroundView = activityIndicator
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
        tableView.backgroundView = nil
    }
}

// - MARK: Table View Selection
extension CoinListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coinViewModel?.showDetail(index: indexPath.row) { coinDetailViewModel in
            let coinDetailViewController = CoinDetailViewController()
            coinDetailViewController.coinDetailViewModel = coinDetailViewModel
            coinDetailViewModel.viewDeleagte = coinDetailViewController
            navigationController?.pushViewController(
                coinDetailViewController,
                animated: true
            )
        }
    }
}

extension CoinListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinViewModel?.sortedCoinDataResponse.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CoinListViewCell.self), for: indexPath) as? CoinListViewCell else { return UITableViewCell() }
        cell.coinInfoResponse = coinViewModel?.sortedCoinDataResponse[indexPath.row]
        return cell
    }
}

// -MARK: Constants
extension CoinListViewController {
    enum Constants {
        static let viewControllerTitle: String = "Coin History"
    }
}
