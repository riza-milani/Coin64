//
//  CoinDetailViewController.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

import UIKit

class CoinDetailViewController: UIViewController {

    var coinDetailViewModel: CoinDetailViewModelProtocol?
    private let dateLabel = UILabel()
    private var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = Constants.viewControllerTitle

        setupDateLabel()
        
        coinDetailViewModel?.getBTCCurrencies { [weak self] result in
            DispatchQueue.main.async {
                if !result.isEmpty {
                    self?.setupCurrencyRows(coinInfoResponses: result)
                }
            }
        }
    }

    private func setupDateLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: Constants.FontSize.primary)
        dateLabel.textColor = .darkGray
        dateLabel.text = coinDetailViewModel?.formattedCurrentDate()
        view.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.padding),
            dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.padding)
        ])
    }

    private func setupCurrencyRows(coinInfoResponses: [CoinInfoResponse]) {
        var previousBottomAnchor = dateLabel.bottomAnchor
        coinInfoResponses
            .sorted { $0.instrument < $1.instrument }
            .forEach { coinInfo in
                let nameLabel = UILabel()
                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                nameLabel.font = UIFont.systemFont(ofSize: Constants.FontSize.secondary)
                nameLabel.text = coinInfo.instrument

                let valueLabel = UILabel()
                valueLabel.translatesAutoresizingMaskIntoConstraints = false
                valueLabel.font = UIFont.systemFont(ofSize: Constants.FontSize.secondary)
                valueLabel.textAlignment = .right
                valueLabel.text = String(format: "%.2f \(coinInfo.currencySymbol)", coinInfo.close)

                view.addSubview(nameLabel)
                view.addSubview(valueLabel)

                NSLayoutConstraint.activate([
                    nameLabel.topAnchor.constraint(equalTo: previousBottomAnchor, constant: Constants.Layout.verticalSpacing),
                    nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.padding),

                    valueLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
                    valueLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.padding),

                    nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.safeAreaLayoutGuide.leadingAnchor, constant: -Constants.Layout.padding)
                ])

                previousBottomAnchor = nameLabel.bottomAnchor
            }
    }
}

// - MARK: Error Handling and Loading Indicator

extension CoinDetailViewController: CoinDetailViewDelegate {
    func showLoading() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()

        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator = indicator
    }

    func hideLoading() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        view.isUserInteractionEnabled = true
        activityIndicator = nil
    }
    func showError(message: String, retryAction: @escaping () -> Void) {
        createErrorView(message: message, retryAction: retryAction)
        hideLoading()
    }

    func hideError() {
        removeErrorView()
    }
}

// - MARK: Constants
extension CoinDetailViewController {
    struct Constants {
        static let viewControllerTitle: String = "Coin Detail"
        struct Layout {
            static let padding: CGFloat = 16
            static let verticalSpacing: CGFloat = 24
        }

        struct FontSize {
            static let primary: CGFloat = 14
            static let secondary: CGFloat = 18
        }
    }
}
