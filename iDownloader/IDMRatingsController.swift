//
//  IDMRatingsController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 23/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMRatingsController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
    }
    
   private func openRateUS(){
        let appStoreLink = "macappstore://itunes.apple.com/app/id1220730126?mt=12"
        if let url = URL(string: appStoreLink){
            NSWorkspace.shared().open(url)
        }
    }
    
    @IBAction func didSelectedRateNow(_ sender: Any) {
        IDMSettingsManager.shared.setAlreadyRated()
        openRateUS()
        self.dismiss(self)
        
    }
    
    @IBAction func didSelectedLater(_ sender: Any) {
        self.dismiss(nil)
        
    }
    
    @IBAction func didSelectedToNotAsk(_ sender: Any) {
        IDMSettingsManager.shared.setNotAsk()
        self.dismiss(nil)
    }
}
