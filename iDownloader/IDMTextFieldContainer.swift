//
//  IDMTextFieldContainer.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMTextFieldContainer: NSView {

    override func viewDidMoveToWindow() {
        self.wantsLayer = true
        self.layer?.borderWidth = 1.0
        self.layer?.cornerRadius = 5
        self.layer?.borderColor = NSColor(IDMr: 151, g: 151, b: 151).cgColor
    }
    
}
