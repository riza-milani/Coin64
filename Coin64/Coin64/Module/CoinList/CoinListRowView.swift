//
//  CoinListRowView.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Updated by Reza on 27.04.25.
//

import SwiftUI

struct CoinListRowView: View {
    let coinInfoResponse: CoinInfoResponse
    let isLatest: Bool

    private var priceFormatter: NumberFormatter {
        PriceFormatter.shared.currencyFormatter(with: coinInfoResponse.currencySymbol)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(coinInfoResponse.timestamp).formattedDate)
                    .font(.headline)

                if isLatest {
                    Text("Latest")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(priceFormatter.string(from: NSNumber(value: coinInfoResponse.close)) ?? "\(coinInfoResponse.close)")
                    .font(.headline)

                HStack(spacing: 4) {
                    Image(systemName: coinInfoResponse.increasingPrice ? "arrow.up" : "arrow.down")
                        .foregroundColor(coinInfoResponse.increasingPrice ? .green : .red)

                    let change = coinInfoResponse.change
                    let percentChange = coinInfoResponse.changePercent

                    Text("\(change, specifier: "%.2f") (\(percentChange, specifier: "%.2f")%)")
                        .font(.caption)
                        .foregroundColor(coinInfoResponse.increasingPrice ? .green : .red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
