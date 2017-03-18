//
//  IDMHighligtingButton.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMHighligtingButton: IDMMouseTrackingButton {

    override func mouseEntered(with event: NSEvent) {
        self.alphaValue = 1.0
    }
    
    override func mouseExited(with event: NSEvent) {
        self.alphaValue = 0.8
    }
    
    override func viewDidMoveToWindow() {
        self.alphaValue = 0.8
    }
    
}
