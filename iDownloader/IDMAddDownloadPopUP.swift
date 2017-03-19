//
//  IDMAddDownloadPopUP.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMAddDownloadPopUP: IDMPopupView {

    @IBOutlet weak var fileTypeLabel: NSTextField!
    @IBOutlet weak var fileNameTextField: NSTextField!
    @IBOutlet weak var downloadLocationTextField: NSTextField!
    @IBOutlet weak var noOfThreadsTextField: NSTextField!
    var outOfSandBoxDirectoryURLData:Data?
    var fileType:fileTypes?
    var downloadURL:String?
    
    final func updateDateUI(fileType:fileTypes, fileName:String, downloadLocation:String, noOfThreads:String, downloadURL:String) {
        self.fileType = fileType
        self.fileTypeLabel.stringValue = fileType.nameForType
        self.fileNameTextField.stringValue = fileName
        self.downloadLocationTextField.stringValue = downloadLocation
        self.noOfThreadsTextField.stringValue = noOfThreads
        self.downloadURL = downloadURL
    }
    
    final func changeDowloadLocation(newFileURL:URL){
        do {
            let bookmarkData = try newFileURL.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            self.outOfSandBoxDirectoryURLData = bookmarkData
            self.downloadLocationTextField.stringValue = newFileURL.path
        }catch  {
            Swift.print(error)
        }
      
    }
   
    
}
