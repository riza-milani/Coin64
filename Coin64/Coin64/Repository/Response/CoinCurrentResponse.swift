//
//  CoinCurrentResponse.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//


struct CoinCurrentResponse: Decodable {
    let currentValue: Double
    let lastTimeStamp: Int
}
