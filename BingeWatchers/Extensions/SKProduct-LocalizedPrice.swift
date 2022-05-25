//
//  SKProduct-LocalizedPrice.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 5/24/22.
//

import StoreKit

// StoreKit products come with price and priceLocale properties, but we need to put them together correctly in order to show our user the correct price for their product
extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
