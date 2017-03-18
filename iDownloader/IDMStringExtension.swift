//
//  IDMStringExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension String {
    
    var isValidUrl:Bool {
        // create NSURL instance
        if let _ = URL(string: self) {
            return true
        }
        return false
    }
}
