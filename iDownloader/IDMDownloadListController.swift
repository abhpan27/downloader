//
//  IDMDownloadListController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMDownloadListController: NSViewController, FileDownloadControllerDelegate {
    
    @IBOutlet weak var loader: NSProgressIndicator!
    @IBOutlet weak var stackView: NSStackView!
    let IDMIntialDownloadProbeHelper = IDMDownloadHeaderFetchHelper()
    var fileDownloaders = [IDMFileDownloadController]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    final func startNewDownload(fileName:String, downloadURL:String, downloadLocation:String, downloadLocationBookMark:Data?, noOfThreads:Int, fileType:fileTypes){
        self.startLoader()
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
            
            runInMainThread {
                blockSelf.stopLoader()
            }
            
            let fileDownloadinfo = blockSelf.fileDownloadInfoForNewDownload(fileName: fileName, downloadURL: downloadURL, downloadLocation: downloadLocation, downloadLocationBookMark: downloadLocationBookMark, noOfThreads: noOfThreads, canBreakIntoSegments: canBreakIntoSegments, contentLength: contentLenght, fileType: fileType)
            blockSelf.addFileDownloader(fileDownloadInfo: fileDownloadinfo)
            
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

//MARK: IDMFileDownloadController
extension IDMDownloadListController {
    
    fileprivate func fileDownloadInfoForNewDownload(fileName:String, downloadURL:String, downloadLocation:String, downloadLocationBookMark:Data?, noOfThreads:Int,  canBreakIntoSegments:Bool, contentLength:Int, fileType:fileTypes) -> FileDownloadDataInfo
    {
        let fileDownloadUniqueID = UUID().uuidString
        let currentTimeStamp = Date().timeIntervalSince1970
        let endTimeStamp = Date().addingTimeInterval(TimeInterval.greatestFiniteMagnitude).timeIntervalSince1970
        
        //create chunks data 
        var chunks = [ChunkDownloadData]()
        let noOfChunks = noOfThreads
        let extraNumberOfBytesForLastDownload = (contentLength % noOfChunks)
        let contentDownloadablePerSession = ((contentLength - extraNumberOfBytesForLastDownload)/noOfChunks)
        var startByteForChunk = 0
        var endByteForChunk = (contentDownloadablePerSession - 1)
        
        for index in 0..<noOfChunks{
            
            let chunckDownloadUniqueID = UUID().uuidString
            let chunkDownloadData = ChunkDownloadData(uniqueID: chunckDownloadUniqueID, startByte: startByteForChunk, endByte: endByteForChunk, totalDownloaded: 0, resumeData: nil, downloadURL: downloadURL)
            chunks.append(chunkDownloadData)
            startByteForChunk = endByteForChunk + 1
            if index < noOfChunks-2 {
                endByteForChunk = (startByteForChunk + contentDownloadablePerSession - 1)
            }else {
                endByteForChunk = (startByteForChunk + contentDownloadablePerSession + extraNumberOfBytesForLastDownload)
            }
        }
        
       let fileDownloadinfo = FileDownloadDataInfo(uniqueID: fileDownloadUniqueID, name: fileName, downloadURL: downloadURL, isResumeSupported: canBreakIntoSegments, type: fileType, startTimeStamp: currentTimeStamp, endTimeStamp: endTimeStamp, diskDownloadLocation: downloadLocation, diskDownloadBookmarkData: downloadLocationBookMark, runningStatus: downloadRunningStatus.running, totalSize: contentLength, chuckDownloadData: chunks, totalDownloaded: 0, currentSpeed: 0, isNewDownload: true)
        
        return fileDownloadinfo
    }
    
    final func addFileDownloader(fileDownloadInfo:FileDownloadDataInfo) {
        let fileDownloader = IDMFileDownloadController(delegate:self)
        self.fileDownloaders.append(fileDownloader)
        fileDownloader.createFileDataHelperAndBeginDownload(fileDownloadInfo: fileDownloadInfo)
    }
    
    //MARK:FileDownloadControllerDelegate
    
    func insertNewDownloadRow(row: NSView) {
        self.stackView.addView(row, in: NSStackViewGravity.top)
    }
    
    func startLoader(){
        self.loader.isHidden = false
        self.loader.startAnimation(self)
    }
    
    func stopLoader(){
        self.loader.isHidden = true
        self.loader.stopAnimation(self)
    }
    
}
