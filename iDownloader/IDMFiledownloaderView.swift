//
//  IDMFiledownloaderView.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 26/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol IDMFiledownloaderViewDelegate:class {
    func didMouseDown()
    func isCompleted() -> Bool
}

class IDMFiledownloaderView: NSView {

    weak var delegate:IDMFiledownloaderViewDelegate?
    fileprivate var trackingArea:NSTrackingArea?
    
    override func updateTrackingAreas()
    {
        if (self.trackingArea != nil) {
            self.removeTrackingArea(trackingArea!)
        }
        
        self.trackingArea = NSTrackingArea(
            rect: self.visibleRect,
            options: [NSTrackingAreaOptions.activeInActiveApp, NSTrackingAreaOptions.cursorUpdate],
            owner: self,
            userInfo: nil
        )
        
        if (self.trackingArea != nil) {
            self.addTrackingArea(self.trackingArea!)
        }
        
        super.updateTrackingAreas()
    }
    
    override func mouseDown(with event: NSEvent) {
        delegate?.didMouseDown()
    }
    
    override func cursorUpdate(with event: NSEvent) {
        if delegate?.isCompleted() ?? false {
             NSCursor.pointingHand().set()
        }else {
             NSCursor.arrow().set()
        }
       
    }
    
    override func resetCursorRects() {
        if delegate?.isCompleted() ?? false {
             self.addCursorRect(self.visibleRect, cursor: NSCursor.pointingHand())
        }
    }
    
}
