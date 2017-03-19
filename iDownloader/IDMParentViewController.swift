//
//  IDMParentViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMParentViewController: NSViewController, HeaderActionDelegate {

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
        sideBarController = IDMSideBarController()
        downloadListController = IDMDownloadListController()
        self.topBarContainer.addFittingSubView(subView: headerController.view)
        self.sideBarContainer.addFittingSubView(subView: sideBarController.view)
        self.listOfDownloadContainer.addFittingSubView(subView: downloadListController.view)
    }
    
    private func intiateDownloadPopUp(downloadUrl: String) {
        guard let urlFromString = URL(string: downloadUrl)
            else {
                return
        }
        
        let fileNameAndExtesion = urlFromString.lastPathComponent.components(separatedBy: ".")
        guard  fileNameAndExtesion.count > 0
            else{
                return
        }
        
        let fileName = fileNameAndExtesion[0]
        let fileExtension =  fileNameAndExtesion.count > 1 ? fileNameAndExtesion[1] : ""
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
        let defaultDownloadLocation = IDMFileManager.shared.defaultDownloadURL.path
        let defaultNoOfThreads = "10"
        addDownloadPopUpView.updateDateUI(fileType: forFileType.nameForType, fileName: fileName, downloadLocation: defaultDownloadLocation, noOfThreads: defaultNoOfThreads, downloadURL:downloadURL)
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
        
        guard let threadCount = Int(self.addDownloadPopUpView.noOfThreadsTextField.stringValue), threadCount > 0 , threadCount < 15
            else {
                showErorr(title: "Invalid no of threads", message: "Please enter a valid no of threads. Valid no of threads should be a number in range of 1-15")
                return
        }
        
        startNewDownload(fileName: self.addDownloadPopUpView.fileNameTextField.stringValue, downloadURL: self.addDownloadPopUpView.downloadURL!, downloadLocation: self.addDownloadPopUpView.downloadLocationTextField.stringValue, downloadLocationBookMark: self.addDownloadPopUpView.outOfSandBoxDirectoryURLData, noOfThreads: threadCount)
        
    }
    
    
    @IBAction func didSelectedStartDownload(_ sender: Any) {
        validateAndStartDownload()
    }
    
}

//MARK:Download start and handling
extension IDMParentViewController {
    
    final func startNewDownload(fileName:String, downloadURL:String, downloadLocation:String, downloadLocationBookMark:Data?, noOfThreads:Int){
        
    }
    
}
