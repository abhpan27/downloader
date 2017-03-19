//
//  IDMReachability.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation

class IDMReachability{
    
    static func isConnectedToInternet() -> Bool{
        let reachabilty = Reachability.forInternetConnection()
        let status = reachabilty?.currentReachabilityStatus()
        return status!.rawValue != 0
    }
}
