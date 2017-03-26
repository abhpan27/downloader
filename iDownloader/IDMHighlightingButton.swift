//
//  IDMHighlightingButton.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 26/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMFullRectColorButton: IDMMouseTrackingButton {

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
        
        super.updateTrackingAreas()
    }
    
    
    var color : NSColor =  NSColor(IDMr: 74, g: 144, b: 226) {
        didSet{
            self.wantsLayer = true
            self.layer?.backgroundColor = color.cgColor
        }
    }
    
    override func viewDidMoveToWindow() {
        self.wantsLayer = true
        self.layer?.backgroundColor = color.cgColor
        self.alphaValue = 0.7
        self.layer?.cornerRadius = self.frame.height/2
        changeTextColor(NSColor.white)
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.alphaValue = 1.0
    }
    
    override func mouseExited(with event: NSEvent) {
        self.alphaValue = 0.8
    }
    
    var intrinsicContentSizeOffset: NSSize = NSZeroSize
    
    override var intrinsicContentSize: NSSize {
        return NSMakeSize(super.intrinsicContentSize.width + 29.0 + intrinsicContentSizeOffset.width, super.intrinsicContentSize.height + 3.0 + intrinsicContentSizeOffset.height)
    }
    
    fileprivate func changeTextColor(_ toColor:NSColor){
        let title = self.title
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        self.attributedTitle = NSAttributedString(string: title, attributes: [NSParagraphStyleAttributeName:paragraphStyle , NSFontAttributeName:self.font as Any, NSBaselineOffsetAttributeName:1,NSForegroundColorAttributeName:toColor])
    }
}
