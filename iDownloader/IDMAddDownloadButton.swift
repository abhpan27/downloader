//
//  IDMAddDownloadButton.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMAddDownloadButton:IDMMouseTrackingButton {
    let defaultColor = NSColor.white.cgColor
    let mouseHoverColor = NSColor(IDMr: 74, g: 144, b: 226).cgColor
    
    override func viewDidMoveToWindow() {
        self.wantsLayer = true
        self.image = NSImage(named: "BluePlus")!
        self.layer?.backgroundColor = defaultColor
    }
    
    override func mouseExited(with event: NSEvent) {
        self.image = NSImage(named: "BluePlus")!
        self.layer?.backgroundColor = defaultColor
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.image = NSImage(named: "whitePlus")!
        self.layer?.backgroundColor = mouseHoverColor
    }
    
    
}
