//
//  IDMDownloadCompleteViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 26/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol FileOpenPopUpDelegate:class {
    func didNotFindFile()
}

class IDMDownloadCompleteViewController: NSViewController {

    @IBOutlet weak var openButton: IDMFullRectColorButton!
    @IBOutlet weak var openfolderButton: IDMFullRectColorButton!
    weak var delegate:FileOpenPopUpDelegate?
    let fileDonwloadInfo:FileDownloadDataInfo
    @IBOutlet weak var imageContainerView: NSView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var fileNameLable: NSTextField!
    @IBOutlet weak var downloadStartedAt: NSTextField!
    @IBOutlet weak var downloadFinishedAt: NSTextField!
    
    init(delegate:FileOpenPopUpDelegate, fileDonwloadInfo:FileDownloadDataInfo){
        self.fileDonwloadInfo = fileDonwloadInfo
        self.delegate = delegate
        super.init(nibName: "IDMDownloadCompleteViewController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        self.imageContainerView.wantsLayer = true
        self.imageContainerView.layer?.backgroundColor = NSColor.clear.cgColor
        self.imageContainerView.layer?.cornerRadius = self.imageContainerView.frame.height/2
        self.imageContainerView.layer?.borderWidth = 1.0
        self.imageContainerView.layer?.borderColor = NSColor(IDMr: 155, g: 155, b: 155).cgColor
        
        self.imageView.image = fileDonwloadInfo.type.imageForFileType
        self.fileNameLable.stringValue = fileDonwloadInfo.name
        self.downloadStartedAt.stringValue =  Date(timeIntervalSince1970: fileDonwloadInfo.startTimeStamp).representableDate
        self.downloadFinishedAt.stringValue = Date(timeIntervalSince1970: fileDonwloadInfo.endTimeStamp).representableDate
        openfolderButton.color = NSColor(IDMr: 71, g: 141, b: 222)
        openButton.color = NSColor(IDMr: 65, g: 117, b: 5)
    }
    
    @IBAction func didSelectedOpenFolder(_ sender: Any) {
        guard let url = IDMFileHandler().isFileAvailable(fileName: self.fileDonwloadInfo.name, containingDirectory: self.fileDonwloadInfo.diskDownloadLocation, fileExtension: URL(string:self.fileDonwloadInfo.downloadURL)!.pathExtension, fileBookMarkData: self.fileDonwloadInfo.diskDownloadBookmarkData)
            else{
                IDMUtilities.shared.showError(title: "File does not exist", information: "File is moved or deleted from original download location")
                delegate?.didNotFindFile()
                self.view.window?.close()
                return
        }
        
        NSWorkspace.shared().activateFileViewerSelecting([url])
    }
    
    @IBAction func didSelectedOpenFile(_ sender: Any) {
        guard let url = IDMFileHandler().isFileAvailable(fileName: self.fileDonwloadInfo.name, containingDirectory: self.fileDonwloadInfo.diskDownloadLocation, fileExtension: URL(string:self.fileDonwloadInfo.downloadURL)!.pathExtension, fileBookMarkData: self.fileDonwloadInfo.diskDownloadBookmarkData)
            else{
                IDMUtilities.shared.showError(title: "File does not exist", information: "File is moved or deleted from original download location")
                delegate?.didNotFindFile()
                self.view.window?.close()
                return
        }
        
        NSWorkspace.shared().open( url)
        
    }
    
}
