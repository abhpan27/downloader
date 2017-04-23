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

protocol SideBarDelegate:class {
    func didSelectedPauseAllInSideBar()
    func didSelectedResumeAllInSideBar()
    func didSelectedSettingsInSideBar()
    func didSelectedFilterInSideBar()
    func didSelectedClearAllInSideBar()
}

class IDMSideBarController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var sideBarTableView: NSTableView!
    fileprivate let actionData = [RowData(image:NSImage(named: "menu")!, actionTitle:"Filter"),RowData(image:NSImage(named: "media-pause")!, actionTitle:"Pause"),RowData(image:NSImage(named: "ResumeWhite")!, actionTitle:"Resume"),RowData(image:NSImage(named: "SettingsSideBar")!, actionTitle:"Settings"), RowData(image:NSImage(named: "clearAll")!, actionTitle:"Clear All")]
    
    weak var delegate:SideBarDelegate?
    
    let filterTableIndex = 0
    let pauseTableIndex = 1
    let resumeIndex = 2
    let settingsIndex = 3
    let clearAllIndex = 4
    
    init(delegate:SideBarDelegate){
        self.delegate = delegate
        super.init(nibName: "IDMSideBarController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideBarTableView.backgroundColor = NSColor.clear
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(IDMr: 74, g: 74, b: 74, alpha:1.0).cgColor
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

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = sideBarTableView.selectedRow
        switch selectedRow {
        case filterTableIndex:
            delegate?.didSelectedFilterInSideBar()
        case pauseTableIndex:
            delegate?.didSelectedPauseAllInSideBar()
        case resumeIndex:
            delegate?.didSelectedResumeAllInSideBar()
        case settingsIndex:
            delegate?.didSelectedSettingsInSideBar()
        case clearAllIndex:
            delegate?.didSelectedClearAllInSideBar()
        default: break
        }
        sideBarTableView.deselectRow(selectedRow)
    }
    
}
