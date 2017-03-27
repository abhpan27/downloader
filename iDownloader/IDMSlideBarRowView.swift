//
//  IDMSlideBarRowView.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 27/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMSlideBarRowView: NSTableRowView {

    @IBOutlet weak var itemLable: NSTextField!
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                self.backgroundColor = NSColor(IDMr: 50, g: 50, b: 50)
            }else {
                self.backgroundColor = NSColor.clear
            }
        }
        
    }
    
}
