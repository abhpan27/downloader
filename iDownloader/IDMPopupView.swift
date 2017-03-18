//
//  IDMPopupView.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMPopupView: NSView {

    override func viewDidMoveToWindow() {
        self.wantsLayer = true
        self.layer?.cornerRadius = 5.0
        self.layer?.borderColor = NSColor(IDMr: 155, g: 155, b: 155).cgColor
        self.layer?.backgroundColor = NSColor.white.cgColor
        self.addShadowWithColor(NSColor.black.withAlphaComponent(0.5), offset: NSMakeSize(0, -2), blur: 10.0, animated: false)
    }
    
    override func mouseDown(with event: NSEvent) {
        //
    }
    
}
