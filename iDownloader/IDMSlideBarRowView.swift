//
//  IDMSlideBarRowView.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 27/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMSlideBarRowView: NSTableRowView {

    @IBOutlet weak var itemLable: NSTextField!
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                self.backgroundColor = NSColor(IDMr: 50, g: 50, b: 50)
            }else {
                self.backgroundColor = NSColor.clear
            }
        }
        
    }
    
    fileprivate var trackingArea:NSTrackingArea?
    
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
    
    override func mouseEntered(with event: NSEvent) {
        if self.isSelected == false{
            self.backgroundColor = NSColor(IDMr: 50, g: 50, b: 50, alpha:0.8)
        }
    
    }
    
    override func mouseExited(with event: NSEvent) {
        if self.isSelected == false {
            self.backgroundColor = NSColor.clear
        }
    }
    
}
