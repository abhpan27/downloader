//
//  IDMProCustomView.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 29/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol IDMProViewClickProtocol:class {
    func didClickedProView()
}

class IDMProCustomView: NSView {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    weak var delegate:IDMProViewClickProtocol?

    override func viewDidMoveToWindow() {
        self.wantsLayer = true
        self.layer?.cornerRadius = self.frame.height/2
        self.layer?.borderWidth = 1.0
        self.layer?.borderColor = NSColor(IDMr: 78, g: 146, b: 223).cgColor
        changeTextColor(NSColor(IDMr: 78, g: 146, b: 223))
    }
    
    fileprivate var trackingArea:NSTrackingArea?
    override func updateTrackingAreas()
    {
        if (self.trackingArea != nil) {
            self.removeTrackingArea(trackingArea!)
        }
        
        self.trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeInActiveApp],
            owner: self,
            userInfo: nil
        )
        
        if (self.trackingArea != nil) {
            self.addTrackingArea(self.trackingArea!)
        }
        
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.alphaValue = 1.0
        self.layer?.backgroundColor = NSColor(IDMr: 78, g: 146, b: 223).cgColor
        changeTextColor(NSColor.white)
        self.imageView.image = NSImage(named:"rowRocketWhite")
    }
    
    override func mouseExited(with event: NSEvent) {
        self.alphaValue = 0.8
        self.layer?.backgroundColor = NSColor.clear.cgColor
        changeTextColor(NSColor(IDMr: 78, g: 146, b: 223))
        self.imageView.image = NSImage(named:"rowRocket")
    }
    
    override func mouseDown(with event: NSEvent) {
        delegate?.didClickedProView()
    }

    
    fileprivate func changeTextColor(_ toColor:NSColor){
        let title = self.titleLabel.stringValue
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        self.titleLabel.attributedStringValue = NSAttributedString(string: title, attributes: [NSParagraphStyleAttributeName:paragraphStyle,  NSBaselineOffsetAttributeName:1,NSForegroundColorAttributeName:toColor])
    }
    
}
