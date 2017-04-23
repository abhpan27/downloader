//
//  IDMMailWindowController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMMailWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        (NSApp.delegate as! AppDelegate).window = self.window!
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility = .hidden
        self.window?.isMovableByWindowBackground = true
        self.window?.delegate = self
        (NSApp.delegate as! AppDelegate).appController.layOutUI()
    }
    
    func window(_ window: NSWindow, willPositionSheet sheet: NSWindow, using rect: NSRect) -> NSRect
    {
        let finalRect = NSMakeRect(rect.minX, rect.minY-75, rect.width, rect.height)
        return finalRect
    }

}
