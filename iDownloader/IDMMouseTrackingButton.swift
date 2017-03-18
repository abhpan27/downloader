//
//  IDMMouseTrackingButton.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMMouseTrackingButton: NSButton {

    fileprivate var trackingArea:NSTrackingArea?
    override var isEnabled: Bool {
        didSet {
            if isEnabled == false {
                if (self.trackingArea != nil) {
                    self.removeTrackingArea(self.trackingArea!)
                }
            } else {
                self.updateTrackingAreas()
            }
        }
    }
    
    override func updateTrackingAreas()
    {
        if (self.trackingArea != nil) {
            self.removeTrackingArea(trackingArea!)
        }
        
        self.trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeInKeyWindow],
            owner: self,
            userInfo: nil
        )
        
        if (self.trackingArea != nil) {
            self.addTrackingArea(self.trackingArea!)
        }
        
        super.updateTrackingAreas()
    }
    
}
