//
//  IDMDownloadListController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMDownloadListController: NSViewController {
    
    let IDMIntialDownloadProbeHelper = IDMDownloadHeaderFetchHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    final func startNewDownload(fileName:String, downloadURL:String, downloadLocation:String, downloadLocationBookMark:Data?, noOfThreads:Int){
        IDMIntialDownloadProbeHelper.fetchHeaderDataForDownloadURL(downloadLink: downloadURL){
            [weak self]
            (error, canBreakIntoSegments, contentLenght)
            in
            guard let blockSelf = self
                else{
                    return
            }
            if error != nil {
                runInMainThread {
                    blockSelf.showError(error: error!)
                }
                return
            }
            
        }
    }
    
    func showError(error:NSError) {
        let title = "Oops!!"
        var message = ""
        if error.domain != DownloadProbeError.errorDomain {
           message = error.localizedDescription
        }else {
            
            switch error.code {
            case DownloadProbeError.codeHeaderNotFound:
                message = "Download Header probe failed. Please try again later"
            case DownloadProbeError.codeNoInternet:
                message = "You are not connected to internet. Please connect and try again"
            case DownloadProbeError.contentLengthNotFoundCode:
                message = "Can not find file download size. Please try again later"
                
            default:
                message = "something went wrong. Please try again later"
            }
        }
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
    
}
