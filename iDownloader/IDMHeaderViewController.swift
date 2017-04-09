//
//  IDMHeaderViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol HeaderActionDelegate:class{
    func didSelectedStartDownloadFromHeader(downloadUrl:String)
    func removeCompletedFiles()
}

class IDMHeaderViewController: NSViewController{

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var downloadLinkTextField: NSTextField!
    @IBOutlet weak var addDownloadContainer: NSView!
    @IBOutlet weak var addButton: NSButton!
    weak var headerActionDelgate:HeaderActionDelegate?
    
    init(headerDelegate:HeaderActionDelegate){
        self.headerActionDelgate = headerDelegate
        super.init(nibName: "IDMHeaderViewController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        addDownloadContainer.wantsLayer = true
        addDownloadContainer?.layer?.borderWidth = 1.0
        addDownloadContainer.layer?.cornerRadius =  5
        addDownloadContainer?.layer?.borderColor = NSColor(IDMr: 178, g: 164, b: 164).cgColor
    }
    
    @IBAction func didSelectedAddDowload(_ sender: Any) {
        checkAndStartDownload()
    }
    
    final func setTitle(tileString:String){
        self.titleLabel.stringValue = tileString
    }
    
    private func checkAndStartDownload() {
        guard !self.downloadLinkTextField.stringValue.isEmpty
            else {
                return
        }
        
        guard  self.downloadLinkTextField.stringValue.isValidUrl
            else{
                showErorr(title: "invalid Url", message: "Download link is not valid, please enter valid download link and try again")
                return
        }
        
        self.headerActionDelgate?.didSelectedStartDownloadFromHeader(downloadUrl: self.downloadLinkTextField.stringValue)
    }
    
    private func showErorr(title:String, message:String) {
        let alert =  NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
    
    
    @IBAction func didSelectedClearDownloads(_ sender: Any) {
        let answer = IDMUtilities.shared.dialogOKCancel(question: "Remove all completed item from App?", text: "If you clear, downloaded files will not be shown in app. It will not delete Downloaded file from your PC")
        if answer {
            self.headerActionDelgate?.removeCompletedFiles()
        }
    }
    
}
