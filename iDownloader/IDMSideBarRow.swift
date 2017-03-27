//
//  IDMSideBarRow.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMSideBarRow: NSView {

     @IBOutlet weak var itemLable: NSTextField!
     @IBOutlet weak var itemImage: NSImageView!
    
    var trackingArea:NSTrackingArea?
    override func updateTrackingAreas() {
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }
        
        trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeInKeyWindow, NSTrackingAreaOptions.mouseMoved],
            owner: self,
            userInfo: nil
        )
        
        if trackingArea != nil {
            self.addTrackingArea(trackingArea!)
        }
        
        var mouseLocation = self.window?.mouseLocationOutsideOfEventStream
        
        mouseLocation = self.convert(mouseLocation!, from: nil)
        if NSPointInRect(mouseLocation!, self.bounds){
            self.mouseEntered(with: NSEvent())
        }
        else{
            self.mouseExited(with: NSEvent())
        }
        super.updateTrackingAreas()
    }
    
    override func viewDidMoveToWindow() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.layer?.backgroundColor = NSColor(IDMr: 50, g: 50, b: 50).cgColor
    }
    
    override func mouseExited(with event: NSEvent) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
}
