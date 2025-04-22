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
    private var errorLabel: UILabel?
    var coinViewModel: CoinListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BTC History"
        view.backgroundColor = .systemBackground
        setupTableView()
        showLoading()
        coinViewModel?.getBTCHistory { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                self?.hideLoading()
                self?.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        coinViewModel?.setRefreshLastPrice(isEnable: true) {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        coinViewModel?.setRefreshLastPrice(isEnable: false) { }
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
}


// - MARK: Loading Indicator

extension CoinListViewController {
    func showLoading() {
        activityIndicator.startAnimating()
        tableView.backgroundView = activityIndicator
    }
    func hideLoading() {
        activityIndicator.stopAnimating()
        tableView.backgroundView = nil
    }
}

// - MARK: Error Handling

extension CoinListViewController: CoinListViewDelegate {
    func showError(message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        errorLabel = label
        hideLoading()
    }

    func hideError() {
        errorLabel?.removeFromSuperview()
        errorLabel = nil
    }
}

// - MARK: Table View Selection
extension CoinListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coinViewModel?.showDetail(index: indexPath.row) { coinDetailViewModel in
            let coinDetailViewController = CoinDetailViewController()
            coinDetailViewController.coinDetailViewModel = coinDetailViewModel
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
