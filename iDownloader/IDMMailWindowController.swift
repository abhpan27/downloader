//
//  IDMMailWindowController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMMailWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        (NSApp.delegate as! AppDelegate).window = self.window!
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility = .hidden
        self.window?.isMovableByWindowBackground = true
        (NSApp.delegate as! AppDelegate).appController.layOutUI()
    }

}
