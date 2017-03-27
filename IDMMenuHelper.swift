//
//  IDMMenuHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 28/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension AppDelegate {
    
    @IBAction func didSelectedPreferences(sender : Any?){
        self.appController.showSettings()
    }
}
