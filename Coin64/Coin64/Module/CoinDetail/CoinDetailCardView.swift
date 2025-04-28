//
//  CoinDetailCardView.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import SwiftUI

struct CoinDetailCardView: View {
    let price: CoinInfoResponse

    private var priceFormatter: NumberFormatter {
        PriceFormatter.shared.currencyFormatter(with: price.currencySymbol)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(price.instrument)
                .font(.title)
                .fontWeight(.bold)

            Divider()

            InfoRow(title: "Close", value: price.close, currencySymbol: price.currencySymbol)
            InfoRow(title: "Open", value: price.open, currencySymbol: price.currencySymbol)
            InfoRow(title: "High", value: price.high, currencySymbol: price.currencySymbol)
            InfoRow(title: "Low", value: price.low, currencySymbol: price.currencySymbol)

            let change = price.close - price.open
            let percentChange = (price.close - price.open) / price.open * 100
            let isPositive = change >= 0

            HStack {
                Text("Change")
                    .fontWeight(.medium)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    Text("\(priceFormatter.string(from: NSNumber(value: abs(change))) ?? "") (\(abs(percentChange), specifier: "%.2f")%)")
                }
                .foregroundColor(isPositive ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    struct InfoRow: View {
        let title: String
        let value: Double
        let currencySymbol: String?

        private var priceFormatter: NumberFormatter {
            PriceFormatter.shared.currencyFormatter(with: currencySymbol ?? "")
        }

        var body: some View {
            HStack {
                Text(title)
                    .fontWeight(.medium)

                Spacer()

                Text(priceFormatter.string(from: NSNumber(value: value)) ?? "\(value)")
            }
        }
    }
}
