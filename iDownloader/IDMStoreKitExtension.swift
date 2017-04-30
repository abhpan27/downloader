//
//  IDMStoreKitExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 30/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import StoreKit

extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
    
}
