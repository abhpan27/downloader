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
        getAllFileDownloadInfoFromDBAndIntializeUI()
    }
    
    final func filterExistingController(filter:DownloadFilter){
        self.removeAllDownloadRows()
        for downloadController in self.fileDownloaders {
            var shouldInsertRow = false
            switch filter{
            case .allDownloads:
                shouldInsertRow = true
            case .videoFiles:
                if downloadController.fileDownloadHelper!.fileDownloadData.type == .video {
                    shouldInsertRow = true
                }
                
            case .compressedFiles:
                if downloadController.fileDownloadHelper!.fileDownloadData.type == .compressed {
                    shouldInsertRow = true
                }
                
            case .otherFiles:
                if downloadController.fileDownloadHelper!.fileDownloadData.type == .other {
                    shouldInsertRow = true
                }
                
            case .documentFiles:
                if downloadController.fileDownloadHelper!.fileDownloadData.type == .document {
                    shouldInsertRow = true
                }
                
            case .imageFiles:
                if downloadController.fileDownloadHelper!.fileDownloadData.type == .picture {
                    shouldInsertRow = true
                }
                
            case .applicationFiles:
                if downloadController.fileDownloadHelper!.fileDownloadData.type == .application {
                    shouldInsertRow = true
                }
            }
            if shouldInsertRow {
                self.insertNewDownloadRow(row: downloadController.view)
            }
        }
    }
    
    private func removeAllDownloadRows() {
        for view in self.stackView.views(in: NSStackViewGravity.center){
            self.stackView.removeView(view)
        }
    }
    
    
    final func startNewDownload(fileName:String, downloadURL:String, downloadLocation:String, downloadLocationBookMark:Data?, noOfThreads:Int, fileType:fileTypes){
        IDMAnalyticsHelper.shared.LogNewDownloadStart()
        self.startLoader()
        IDMIntialDownloadProbeHelper.fetchHeaderDataForDownloadURL(downloadLink: downloadURL){
            [weak self]
            (error, canBreakIntoSegments, contentLenght)
            in
            guard let blockSelf = self
                else{
                    return
            }
            
            runInMainThread {
                blockSelf.stopLoader()
            }
            if error != nil {
                runInMainThread {
                    blockSelf.showError(error: error!)
                }
                return
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
    
    //pause all download one by one
    final func pauseAllDownloads(completion:@escaping () -> ()) {
        pauseAllRecursively(index: 0, completion: completion)
    }
    
    //resume all download one by one
    
    final func resumeAllDownloads(completion:@escaping () -> ()){
        resumeAllRescusively(index: 0, completion: completion)
    }
    
    private func pauseAllRecursively(index:Int, completion:@escaping () -> ()) {
        if index >= self.fileDownloaders.count {
            completion()
            return
        }
        
        fileDownloaders[index].pauseDownload {
            [weak self]
            in
            guard let blockSelf = self
                else {
                    return
            }
            blockSelf.pauseAllRecursively(index: index + 1, completion: completion)
        }
    }
    private func resumeAllRescusively(index:Int, completion:@escaping () -> ()) {
        if index >= self.fileDownloaders.count {
            completion()
            return
        }
        
        fileDownloaders[index].resumeDownload {
            [weak self]
            in
            guard let blockSelf = self
                else {
                    return
            }
            blockSelf.resumeAllRescusively(index: index + 1, completion: completion)
        }
    }
    
    private func getAllFileDownloadInfoFromDBAndIntializeUI() {
        self.startLoader()
        IDMCoreDataHelper.shared.getAllTheFileDownloadInfoFromDB {[weak self]
            (error, fileInfoArray)
            in
            guard let blockSelf = self
                else{
                    return
            }
            if fileInfoArray.count > 0{
                 blockSelf.createControllersAndStartDownloading(fileInfoArray: fileInfoArray)
            }
            runInMainThread {
                blockSelf.stopLoader()
            }
        }
    }
    
    private func createControllersAndStartDownloading(fileInfoArray:[FileDownloadDataInfo]) {
        let shouldResumeAllDownload = false
        
        for fileInfo in fileInfoArray {
            let fileDownloadController = IDMFileDownloadController(delegate: self)
            self.fileDownloaders.append(fileDownloadController)
            fileDownloadController.createFileDataHelperAndBeginDownload(fileDownloadInfo: fileInfo, shouldForceStartPauseDownload:shouldResumeAllDownload)
            
        }
    }
    
    final func clearAllCompletedDownloads() {
        var arrayOfFileDownlodesToRamove = [FileDownloadDataInfo]()
        var arrayOfRowsToRemove = [NSView]()
        for item in self.fileDownloaders {
            if item.fileDownloadHelper?.fileDownloadData.runningStatus == .completed {
                arrayOfFileDownlodesToRamove.append(item.fileDownloadHelper!.fileDownloadData)
                arrayOfRowsToRemove.append(item.view)
            }
        }
        
        //remove all download objects
        for view in arrayOfRowsToRemove {
            if stackView.views.contains(view){
                   self.stackView.removeView(view)
            }
        }
        
        //remove fileDownloaders 
        for item in arrayOfFileDownlodesToRamove {
            if let index = self.fileDownloaders.index(where: { (downloader) -> Bool in
                return (downloader.fileDownloadHelper!.fileDownloadData.uniqueID == item.uniqueID)
            }){
                self.fileDownloaders.remove(at: index)
            }
        }
        
        //remove from DB 
        IDMCoreDataHelper.shared.deleteAllCompletedDownloadsEntry { (error) in
            //do nothing
        }
        
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
        let noOfChunks = canBreakIntoSegments ? noOfThreads : 1
        let extraNumberOfBytesForLastDownload = (contentLength % noOfChunks)
        let contentDownloadablePerSession = ((contentLength - extraNumberOfBytesForLastDownload)/noOfChunks)
        var startByteForChunk = 0
        var endByteForChunk = (contentDownloadablePerSession - 1)
        
        for index in 0..<noOfChunks{
            
            let chunckDownloadUniqueID = UUID().uuidString
            let chunkDownloadData = ChunkDownloadData(uniqueID: chunckDownloadUniqueID, startByte: startByteForChunk, endByte: endByteForChunk, totalDownloaded: 0, downloadURL: downloadURL, isCompleted:false)
            chunks.append(chunkDownloadData)
            startByteForChunk = endByteForChunk + 1
            if index < noOfChunks-2 {
                endByteForChunk = (startByteForChunk + contentDownloadablePerSession - 1)
            }else {
                endByteForChunk = (startByteForChunk + contentDownloadablePerSession + extraNumberOfBytesForLastDownload-1)
            }
        }
        
       let fileDownloadinfo = FileDownloadDataInfo(uniqueID: fileDownloadUniqueID, name: fileName, downloadURL: downloadURL, isResumeSupported: canBreakIntoSegments, type: fileType, startTimeStamp: currentTimeStamp, endTimeStamp: endTimeStamp, diskDownloadLocation: downloadLocation, diskDownloadBookmarkData: downloadLocationBookMark, runningStatus: downloadRunningStatus.running, totalSize: contentLength, chuckDownloadData: chunks, totalDownloaded: 0, currentSpeed: 0, isNewDownload: true)
        
        return fileDownloadinfo
    }
    
    final func addFileDownloader(fileDownloadInfo:FileDownloadDataInfo) {
        let fileDownloader = IDMFileDownloadController(delegate:self)
        self.fileDownloaders.append(fileDownloader)
        fileDownloader.createFileDataHelperAndBeginDownload(fileDownloadInfo: fileDownloadInfo, shouldForceStartPauseDownload: false)
    }
    
    //MARK:FileDownloadControllerDelegate
    
    func insertNewDownloadRow(row: NSView) {
        self.stackView.addView(row, in: NSStackViewGravity.center)
    }
    
    func startLoader(){
        self.loader.isHidden = false
        self.loader.startAnimation(self)
    }
    
    func stopLoader(){
        self.loader.isHidden = true
        self.loader.stopAnimation(self)
    }
    
    func removeDownloader(downloadController:IDMFileDownloadController){
        self.stackView.removeView(downloadController.view)
        if let index = self.fileDownloaders.index(where: { (downloader) -> Bool in
            return downloader == downloadController
        }){
            self.fileDownloaders.remove(at: index)
        }
    }
    
    func scrollToBottom(){
        self.stackView.enclosingScrollView?.scrollToBottom()
    }
    
}
