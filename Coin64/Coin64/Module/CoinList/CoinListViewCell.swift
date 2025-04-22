//
//  CoinListCell.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

import UIKit

class CoinListViewCell: UITableViewCell {
    private let label = UILabel()
    let nameLabel = UILabel()
    let valueLabel = UILabel()
    var coinInfoResponse: CoinInfoResponse? {
        didSet {
            configure(with: coinInfoResponse)
        }
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Constants.Layout.padding)
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: Constants.FontSize.primary)
        contentView.addSubview(label)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: Constants.FontSize.primary)


        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.systemFont(ofSize: Constants.FontSize.primary)
        valueLabel.textAlignment = .right

        contentView.addSubview(nameLabel)
        contentView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.padding),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.paddingSmall),

            nameLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Constants.Layout.padding),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.padding),

            valueLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.padding),

            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -Constants.Layout.paddingSmall),

            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.paddingSmall),

        ])
    }

    func configure(with info: CoinInfoResponse?) {
        label.text = "\(String(coinInfoResponse?.timestamp ?? 0).formattedDate)"
        nameLabel.text = "Last Price:"
        valueLabel.text = String(format: "%.2f EUR", coinInfoResponse?.close ?? 0)
    }
}

// - MARK: Constants
extension CoinListViewCell {
    struct Constants {
        struct Layout {
            static let padding: CGFloat = 16
            static let paddingSmall: CGFloat = 8
        }

        struct FontSize {
            static let primary: CGFloat = 18
        }
    }
}
