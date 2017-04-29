//
//  IDMProWindowController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 29/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMProWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility = .hidden
        self.window?.isMovableByWindowBackground = true
        self.window?.backgroundColor = NSColor.white
        let maximize = self.window?.standardWindowButton(NSWindowButton.zoomButton)
        maximize?.isHidden = true
    }
    
}
