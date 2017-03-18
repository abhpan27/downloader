//
//  IDMHeaderViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMHeaderViewController: NSViewController {

   
    @IBOutlet weak var addDownloadContainer: NSView!
    @IBOutlet weak var addButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        addDownloadContainer.wantsLayer = true
        addDownloadContainer?.layer?.borderWidth = 1.0
        addDownloadContainer.layer?.cornerRadius =  5
        addDownloadContainer?.layer?.borderColor = NSColor(IDMr: 178, g: 164, b: 164).cgColor
    }
    
}
