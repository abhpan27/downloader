//
//  IDMParentViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

enum DownloadFilter:Int {
    case allDownloads = 0, paused, completed, running, videoFiles, documentFiles, applicationFiles, compressedFiles,
    imageFiles, otherFiles
    
    var stringForRow:String {
        switch self {
        case .allDownloads:
            return "All Downloads"
        case .paused:
            return "Paused"
        case .completed:
            return "Completed"
        case .running:
            return "Running"
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
    @IBOutlet weak var fileTypeLabel: NSTextField!
    @IBOutlet weak var downloadFolderTextField: NSTextField!
    @IBOutlet weak var fileNameTextField: NSTextField!
    @IBOutlet weak var threadsTextField: NSTextField!
    @IBOutlet weak var addDownloadPopUpView: IDMAddDownloadPopUP!
    @IBOutlet var addDownloadContainer: IDMMouseEventBlockingView!
    var isNavBarOpen = false
    var lastSelectedIndex = -1
    
    let arrayOfFilters:[DownloadFilter] = [.allDownloads, .paused, .completed, .running, .videoFiles, .documentFiles, .applicationFiles, .compressedFiles, .imageFiles, .otherFiles]
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
    }
    
    
    private func intiateDownloadPopUp(downloadUrl: String) {
        guard let urlFromString = URL(string: downloadUrl)
            else {
                return
        }
        
        let fileNameAndExtesion = urlFromString.lastPathComponent.components(separatedBy: ".")
        
        let fileName = fileNameAndExtesion[0]
        let fileExtension =  urlFromString.pathExtension
        let fileType = IDMFileTypeHelper().getFileType(fileExtension: fileExtension)
       //show popup
        setUpUIandAddDownloadPopUp(forFileType: fileType, fileName: fileName, downloadURL:downloadUrl)
    }

    //MARK:HeaderActionDelegate
    func didSelectedStartDownloadFromHeader(downloadUrl: String) {
        intiateDownloadPopUp(downloadUrl:downloadUrl)
    }
    
}

//MARK: Add download UI
extension IDMParentViewController: MouseDownDelgate {
    final func setUpUIandAddDownloadPopUp(forFileType:fileTypes, fileName:String, downloadURL:String) {
        self.view.addFittingSubView(subView: addDownloadContainer)
        addDownloadContainer.delegate = self
        let defaultDownloadLocation = IDMSettingsManager.shared.defaultDownloadPath
        let defaultNoOfThreads = "\(IDMSettingsManager.shared.defaultNumberOfSegments)"
        let defaultBookMark = IDMSettingsManager.shared.defaultBookMarkData
        addDownloadPopUpView.updateDateUI(fileType: forFileType, fileName: fileName, downloadLocation: defaultDownloadLocation, noOfThreads: defaultNoOfThreads, downloadURL:downloadURL, downloadBookMarkDaat: defaultBookMark)
    }
    
    func didMouseDown() {
        addDownloadContainer.delegate = nil
        addDownloadContainer.removeFromSuperview()
    }
    
    @IBAction func didSelectedChooseDownloadLocation(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                guard let selectedURL = openPanel.url
                    else{
                        return
                }
                self.addDownloadPopUpView.changeDowloadLocation(newFileURL: selectedURL)
                
            }
        }
    }
    
    private func showErorr(title:String, message:String) {
        let alert =  NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
    
    final func validateAndStartDownload(){
        guard !self.addDownloadPopUpView.fileNameTextField.stringValue.isEmpty
            else {
                showErorr(title: "Invalid File name", message: "Please enter a valid file name")
                return
        }
        
        guard !self.addDownloadPopUpView.downloadLocationTextField.stringValue.isEmpty
            else {
                showErorr(title: "Invalid download location", message: "Please select a valid download location")
                return
        }
        
        guard let threadCount = Int(self.addDownloadPopUpView.noOfThreadsTextField.stringValue), threadCount > 0 , threadCount <= 15
            else {
                showErorr(title: "Invalid no of threads", message: "Please enter a valid no of threads. Valid no of threads should be a number in range of 1-15")
                return
        }
        
        self.downloadListController.startNewDownload(fileName: self.addDownloadPopUpView.fileNameTextField.stringValue, downloadURL: self.addDownloadPopUpView.downloadURL!, downloadLocation: self.addDownloadPopUpView.downloadLocationTextField.stringValue, downloadLocationBookMark: self.addDownloadPopUpView.outOfSandBoxDirectoryURLData, noOfThreads: threadCount, fileType:self.addDownloadPopUpView.fileType!)
        self.addDownloadContainer.removeFromSuperview()
        
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
    
    
    @IBAction func didSelectedStartDownload(_ sender: Any) {
        validateAndStartDownload()
    }
    
}

//MARK:side bar filter handling
extension IDMParentViewController:SideBarDelegate {
    
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
    
    func didSelectedRateUsInSideBar(){
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
            self.lastSelectedIndex = selectedItem.rawValue
        }
        
    }
    func didMouseExit() {
        self.slideCloseNavBar()
    }
    
}
