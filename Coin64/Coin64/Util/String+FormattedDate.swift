//
//  String+FormattedDate.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//

import Foundation

extension String {
    var formattedDate: String {
        let timestamp = Double(self) ?? Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}
