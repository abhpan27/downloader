//
//  IDMWindowController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 26/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol IDMPopUpDelgate:class {
    func didCloseWindow(sender:IDMWindowController)
}

class IDMWindowController: NSWindowController, NSWindowDelegate {
    
    weak var delegate:IDMPopUpDelgate?
    var shouldCloseOnResignKey = true
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility = .hidden
        self.window?.isMovableByWindowBackground = true
        self.window?.backgroundColor = NSColor.white
        self.window?.delegate = self
        let maximize = self.window?.standardWindowButton(NSWindowButton.zoomButton)
        maximize?.isHidden = true
    }
    
    func windowWillClose(_ notification: Notification) {
        self.delegate?.didCloseWindow(sender: self)
    }
    
    func windowDidResignKey(_ notification: Notification) {
        if shouldCloseOnResignKey{
            self.close()
            self.delegate?.didCloseWindow(sender: self)
        }
    }
    
}
