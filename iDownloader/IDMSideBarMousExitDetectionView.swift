//
//  IDMSideBarMousExitDetectionView.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 27/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol mouseExitDetection:class {
    func didMouseExit()
}

class IDMSideBarMousExitDetectionView: NSView {

    fileprivate var trackingArea:NSTrackingArea?
    weak var delegate:mouseExitDetection?
    
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
    
    override func mouseExited(with event: NSEvent) {
        self.perform(#selector(IDMSideBarMousExitDetectionView.fireDelegate), with: nil, afterDelay: 0.5)
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
   @objc func fireDelegate() {
        delegate?.didMouseExit()
    }
    
}
