//
//  IDMStartDownloadViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 25/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

struct StartDownloadData{
    let fileName:String
    let downloadURL:String
    let downloadLocation:String
    let downloadBookMarkData:Data?
    let numberOfSegements:Int
    let fileType:fileTypes
}

protocol StartDownloadPopUpDelegate:class {
    func startDownloadWithDownloadData(data:StartDownloadData)
}

class IDMStartDownloadViewController: NSViewController {
    
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var fileNameTextField: NSTextField!
    @IBOutlet weak var downloadFolderTextField: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var tagsPopUp: NSPopUpButton!
    @IBOutlet weak var numberOfSegmentsPopUp: NSPopUpButton!
    var outOfSandBoxDirectoryURLData:Data?
    @IBOutlet weak var passowrdTitle: NSTextField!
    @IBOutlet weak var userNameTitle: NSTextField!
    @IBOutlet weak var authCheckBox: NSButton!
    weak var delegate:StartDownloadPopUpDelegate?
    var fileType:fileTypes?
    
    let downloadURL:String
    init(downloadURL:String, delegate:StartDownloadPopUpDelegate?){
        self.delegate = delegate
        self.downloadURL = downloadURL
        super.init(nibName: "IDMStartDownloadViewController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intializeUI()
        // Do view setup here.
    }
    
    private func intializeUI(){
        guard let urlFromString = URL(string: downloadURL)
            else {
                return
        }
        
        let fileNameAndExtesion = urlFromString.lastPathComponent.components(separatedBy: ".")
        let fileName = fileNameAndExtesion[0]
        let fileExtension =  urlFromString.pathExtension
        fileType = IDMFileTypeHelper().getFileType(fileExtension: fileExtension)
        fileNameTextField.stringValue = fileName
        downloadFolderTextField.stringValue = IDMSettingsManager.shared.defaultDownloadPath
        setUpNoOfSegments()
        setUpUsernameAndPassword()
    }
    
    private func setUpNoOfSegments() {
        let noOfSegmentArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
        numberOfSegmentsPopUp.addItems(withTitles: noOfSegmentArray)
        numberOfSegmentsPopUp.selectItem(withTitle: "\(IDMSettingsManager.shared.defaultNumberOfSegments)")
    }
    
    
    private func setUpUsernameAndPassword() {
        if self.authCheckBox.state == NSOnState {
            usernameTextField.isHidden = false
            passwordTextField.isHidden = false
            passowrdTitle.isHidden = false
            userNameTitle.isHidden = false
            changeWindowSize(shouldIncrease: true)
        }else{
            usernameTextField.isHidden = true
            passwordTextField.isHidden = true
            passowrdTitle.isHidden = true
            userNameTitle.isHidden = true
            changeWindowSize(shouldIncrease: false)
        }
    }
    
    fileprivate func changeWindowSize(shouldIncrease:Bool){
        if self.view.window == nil{
            return
        }
        let currentWindowRect = self.view.window!.frame
        let newWindowHeight:CGFloat = shouldIncrease ? 325 : 275
        let newMinY = currentWindowRect.minY + (currentWindowRect.height - newWindowHeight)
        let newRect = NSMakeRect(currentWindowRect.minX, newMinY, currentWindowRect.width, newWindowHeight)
        self.view.window?.setFrame(newRect, display: false, animate: true)
    }
    
    @IBAction func didSelectedChangeFolder(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { [weak self]
            (result) -> Void
            in
            guard let blockSelf = self
                else{
                    return
            }
            if result == NSFileHandlingPanelOKButton {
                guard let selectedURL = openPanel.url
                    else{
                        return
                }
                blockSelf.changeDowloadLocation(newFileURL: selectedURL)
                
            }
        }
    }
    
    
    private func changeDowloadLocation(newFileURL:URL){
        do {
            let bookmarkData = try newFileURL.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            self.outOfSandBoxDirectoryURLData = bookmarkData
            self.downloadFolderTextField.stringValue = newFileURL.path
        }catch  {
            Swift.print(error)
        }
        
    }
    
    @IBAction func didChangedNumberOfSegments(_ sender: Any) {
        
    }
    
    @IBAction func didChangedAuthenticationRequired(_ sender: Any) {
        setUpUsernameAndPassword()
    }
    
    
    @IBAction func didSelectedStartDownload(_ sender: Any) {
        guard !self.fileNameTextField.stringValue.isEmpty
            else {
                IDMUtilities.shared.showError(title: "Invalid File name", information: "Please enter a valid file name")
                return
        }
        
        guard !self.downloadFolderTextField.stringValue.isEmpty
            else {
                IDMUtilities.shared.showError(title: "Invalid File name", information: "Please enter a valid file name")
                return
        }
        let numberOFSegments = Int(numberOfSegmentsPopUp.titleOfSelectedItem!)!
        let startDownloadData = StartDownloadData(fileName: self.fileNameTextField.stringValue,downloadURL:self.downloadURL, downloadLocation: self.downloadFolderTextField.stringValue, downloadBookMarkData: self.outOfSandBoxDirectoryURLData, numberOfSegements: numberOFSegments, fileType: fileType!)
        delegate?.startDownloadWithDownloadData(data:startDownloadData)
    }
    
    
    
    
}
