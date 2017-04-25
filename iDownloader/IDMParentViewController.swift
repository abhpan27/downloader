//
//  IDMParentViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

enum DownloadFilter:Int {
    case allDownloads = 0, videoFiles, documentFiles, applicationFiles, compressedFiles,
    imageFiles, otherFiles
    
    var stringForRow:String {
        switch self {
        case .allDownloads:
            return "All Downloads"
        case .videoFiles:
            return "Videos"
        case .documentFiles:
            return "Documents"
        case .applicationFiles:
            return "Applications"
        case .compressedFiles:
            return "Compressed"
        case .imageFiles:
            return "Images"
        case .otherFiles:
            return "Other Files"
        }
    }
}

class IDMParentViewController: NSViewController, HeaderActionDelegate {

    @IBOutlet weak var sideBarTableView: NSTableView!
    @IBOutlet weak var navBarSeperator: NSView!
    @IBOutlet weak var navBarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBarContainer: IDMSideBarMousExitDetectionView!
    @IBOutlet weak var filtersContainer: NSView!
    @IBOutlet weak var sideBarContainer: NSView!
    @IBOutlet weak var topBarContainer: NSView!
    @IBOutlet weak var listOfDownloadContainer: NSView!
    @IBOutlet var dropLinkOverlay: NSView!
    
    
    var startDownloadWindowController:NSWindowController?
    var isNavBarOpen = false
    var lastSelectedIndex = -1
    
    let arrayOfFilters:[DownloadFilter] = [.allDownloads, .videoFiles, .documentFiles, .applicationFiles, .compressedFiles, .imageFiles, .otherFiles]
    var currentFilter = DownloadFilter.allDownloads
    
    var headerController:IDMHeaderViewController!
    var sideBarController:IDMSideBarController!
    var downloadListController:IDMDownloadListController!
    
    init() {
        super.init(nibName: "IDMParentViewController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        headerController = IDMHeaderViewController(headerDelegate:self)
        sideBarController = IDMSideBarController(delegate:self)
        downloadListController = IDMDownloadListController()
        self.topBarContainer.addFittingSubView(subView: headerController.view)
        self.sideBarContainer.addFittingSubView(subView: sideBarController.view)
        self.listOfDownloadContainer.addFittingSubView(subView: downloadListController.view)
        self.navBarLeadingConstraint.constant = -105
        self.navBarContainer.wantsLayer = true
        self.navBarContainer.layer?.backgroundColor = NSColor(IDMr: 74, g: 74, b: 74, alpha:1.0).cgColor
        navBarSeperator.wantsLayer = true
        navBarSeperator.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        sideBarTableView.backgroundColor = NSColor.clear
        (self.view as! IDMDragLinkDetectorView).delegate = self
    }
    
    override func viewDidAppear() {
        headerController.setTitle(tileString: currentFilter.stringForRow)
    }
    
    
    final func intiateDownloadPopUp(downloadUrl: String) {
        guard let urlFromString = URL(string: downloadUrl)
            else {
                return
        }
        
        guard let scheme = urlFromString.scheme, scheme.lowercased() == "http" || scheme.lowercased() == "https"
            else {
            IDMUtilities.shared.showError(title: "Opps!", information: "Only Http and Https downloads are supported")
            return
        }
        
       //show popup
        setUpUIandAddDownloadPopUp(downloadURL:downloadUrl)
    }

    //MARK:HeaderActionDelegate
    func didSelectedStartDownloadFromHeader(downloadUrl: String) {
        intiateDownloadPopUp(downloadUrl:downloadUrl)
    }
    
    func removeCompletedFiles(){
        self.downloadListController.clearAllCompletedDownloads()
    }
    
}

//MARK: Add download UI
extension IDMParentViewController: StartDownloadPopUpDelegate {
    final func setUpUIandAddDownloadPopUp(downloadURL:String) {
        startDownloadWindowController?.close()
        startDownloadWindowController = nil
        startDownloadWindowController = IDMStartDownloadWindowController(windowNibName: "IDMStartDownloadWindowController")
        startDownloadWindowController?.contentViewController = IDMStartDownloadViewController(downloadURL:downloadURL, delegate:self)
        let withSize:NSSize = NSSize(width: 475, height: 275)
        let rect = self.startDownloadWindowController!.window!.getRectOfWindowInMiddle((NSApp.delegate as! AppDelegate).window, withSize:withSize)
        self.startDownloadWindowController!.window!.setFrame(rect, display: true)
        self.startDownloadWindowController!.window!.makeKeyAndOrderFront(self)
        
    }
    
    func startDownloadWithDownloadData(data: StartDownloadData) {
        self.downloadListController.startNewDownload(fileName: data.fileName, downloadURL: data.downloadURL, downloadLocation: data.downloadLocation, downloadLocationBookMark: data.downloadBookMarkData, noOfThreads: data.numberOfSegements, fileType: data.fileType)
        self.startDownloadWindowController?.close()
        self.startDownloadWindowController = nil
    }
    
    
    private func showErorr(title:String, message:String) {
        let alert =  NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
    
    
    fileprivate func checkAndCloseOrOpenNavBar() {
        if self.isNavBarOpen {
            slideCloseNavBar()
        }else {
            slideOpenNavBar()
        }
    }
    
    fileprivate func slideOpenNavBar() {
        guard !self.isNavBarOpen
            else {
                return
        }
       
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.navBarLeadingConstraint.animator().constant = 71
            
        }, completionHandler: {
            self.isNavBarOpen = true
             self.navBarContainer.delegate = self
            if self.lastSelectedIndex == -1 {
                self.sideBarTableView.rowView(atRow: self.currentFilter.rawValue, makeIfNecessary: true)?.isSelected = true
            }
        })
    }
    
    fileprivate func slideCloseNavBar() {
        guard self.isNavBarOpen
            else {
                return
        }
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.navBarLeadingConstraint.animator().constant = -105
            
        }, completionHandler: {
            self.isNavBarOpen = false
             self.navBarContainer.delegate = nil
            
        })
    }
    
}

//MARK:side bar filter handling
extension IDMParentViewController:SideBarDelegate {
    internal func didSelectedClearAllInSideBar() {
        let answer = IDMUtilities.shared.dialogOKCancel(question: "Remove all completed item from App?", text: "If you clear, downloaded files will not be shown in app. It will not delete Downloaded file from your PC")
        if answer {
            self.removeCompletedFiles()
        }
    }

    
    func didSelectedPauseAllInSideBar(){
        self.downloadListController.pauseAllDownloads {
            //
        }
    }
    
    func didSelectedResumeAllInSideBar(){
        self.downloadListController.resumeAllDownloads {
            //
        }
    }
    
    func didSelectedSettingsInSideBar(){
        (NSApp.delegate as! AppDelegate).appController.showSettings()
    }
    
    func didSelectedFilterInSideBar(){
        checkAndCloseOrOpenNavBar()
        
    }
}

extension IDMParentViewController:NSTableViewDelegate, NSTableViewDataSource, mouseExitDetection {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.arrayOfFilters.count
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = self.sideBarTableView.make(withIdentifier: "IDMSlideBarRowView", owner: self) as! IDMSlideBarRowView
        rowView.itemLable.stringValue = self.arrayOfFilters[row].stringForRow
        return rowView
    }

    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if let selectedItem = DownloadFilter(rawValue: self.sideBarTableView.selectedRow){
            if self.lastSelectedIndex == -1 {
                self.sideBarTableView.rowView(atRow: self.currentFilter.rawValue, makeIfNecessary: true)?.setBackgroundColor(color: NSColor.clear)
            }
            self.currentFilter = selectedItem
            self.slideCloseNavBar()
            self.downloadListController.filterExistingController(filter: selectedItem)
            self.headerController.setTitle(tileString: currentFilter.stringForRow)
            self.lastSelectedIndex = selectedItem.rawValue
        }
        
    }
    func didMouseExit() {
        self.slideCloseNavBar()
    }
    
}

extension IDMParentViewController:IDMDragLinkDetectorViewDelegate {
    func showOverlay() {
        self.dropLinkOverlay.removeFromSuperview()
        self.dropLinkOverlay.wantsLayer = true
        self.dropLinkOverlay.layer?.backgroundColor = NSColor(IDMr: 255, g: 255, b: 255, alpha: 0.5).cgColor
        self.view.addFittingSubView(subView: self.dropLinkOverlay)
    }
    
    func removeOverlay() {
        self.dropLinkOverlay.removeFromSuperview()
    }
    
    func didDroppedLink(path: String) {
         self.dropLinkOverlay.removeFromSuperview()
        self.intiateDownloadPopUp(downloadUrl:path)
    }
}
