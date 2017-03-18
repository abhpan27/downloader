//
//  IDMSideBarController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

fileprivate struct RowData {
    let image:NSImage
    let actionTitle:String
}

class IDMSideBarController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var sideBarTableView: NSTableView!
    fileprivate let actionData = [RowData(image:NSImage(named: "menu")!, actionTitle:"Filter"),RowData(image:NSImage(named: "media-pause")!, actionTitle:"Pause"),RowData(image:NSImage(named: "ResumeWhite")!, actionTitle:"Resume"),RowData(image:NSImage(named: "SettingsSideBar")!, actionTitle:"Settings"),RowData(image:NSImage(named: "Rate")!, actionTitle:"Rate Us")]
    override func viewDidLoad() {
        super.viewDidLoad()
        sideBarTableView.backgroundColor = NSColor.clear
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(IDMr: 74, g: 74, b: 74, alpha:0.86).cgColor
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = sideBarTableView.make(withIdentifier: "IDMSideBarRow", owner: self) as! IDMSideBarRow
        view.itemImage.image = actionData[row].image
        view.itemLable.stringValue = actionData[row].actionTitle
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 55
    }
    
}
