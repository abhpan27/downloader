//
//  IDMUtilities.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 20/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

final class IDMUtilities {
    static let shared = IDMUtilities()
    
    func showError(title:String, information:String){
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = information
        alert.runModal()
    }
}
