//
//  IDMCustomGreenButton.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMCustomGreenButton: NSButton {

    fileprivate var trackingArea:NSTrackingArea?
    
    let mouseHoverColor = NSColor(IDMr: 121, g: 194, b: 36)
    let defColor = NSColor(IDMr: 106, g: 181, b: 24)
    let clickColor = NSColor(IDMr: 106, g: 181, b: 24)
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
    override func viewDidMoveToWindow()
    {
        self.wantsLayer = true
        self.layer?.borderWidth = 1.0
        self.layer?.cornerRadius = 5
        self.layer?.borderColor = defColor.cgColor
        self.layer?.backgroundColor = NSColor.white.cgColor
        changeTextColor(NSColor(IDMr: 86, g: 173, b: 104))
    }
    
    override func mouseEntered(with theEvent: NSEvent)
    {
        if (self.isEnabled) {
            self.layer?.backgroundColor = mouseHoverColor.cgColor
            changeTextColor(NSColor.white)
        }
    }
    
    override func mouseExited(with theEvent: NSEvent)
    {
        if (self.isEnabled) {
            self.layer?.backgroundColor = NSColor.white.cgColor
            changeTextColor(NSColor(IDMr: 86, g: 173, b: 104))
        }
    }
    
    override func mouseDown(with theEvent: NSEvent)
    {
        if (self.isEnabled) {
            self.layer?.backgroundColor = clickColor.cgColor
            changeTextColor(NSColor.white)
            super.mouseDown(with: theEvent)
            delay(0.15) { [weak self]() -> () in
                if let blockSelf = self {
                    blockSelf.layer?.backgroundColor = blockSelf.mouseHoverColor.cgColor
                    blockSelf.changeTextColor(NSColor.white)
                }
                
            }
        }
    }
    
    fileprivate func changeTextColor(_ toColor:NSColor){
        let title = self.title
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        self.attributedTitle = NSAttributedString(string: title, attributes: [NSParagraphStyleAttributeName:paragraphStyle , NSFontAttributeName:self.font as Any, NSBaselineOffsetAttributeName:1,NSForegroundColorAttributeName:toColor])
    }
    var intrinsicContentSizeOffset: NSSize = NSZeroSize
    
    override var intrinsicContentSize: NSSize {
        return NSMakeSize(super.intrinsicContentSize.width + 10.0 + intrinsicContentSizeOffset.width, super.intrinsicContentSize.height + 3.0 + intrinsicContentSizeOffset.height)
    }
    
}
