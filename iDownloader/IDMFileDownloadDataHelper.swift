//
//  IDMFileDownloadDataHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

enum downloadRunningStatus:String{
    case running = "running", paused = "paused", failed = "failed", completed = "completed"
}

struct FileDownloadDataInfo{
    let uniqueID:String
    var name:String
    let downloadURL:String
    let isResumeSupported:Bool
    let type:fileTypes
    var startTimeStamp:Double
    var endTimeStamp:Double
    let diskDownloadLocation:String
    let diskDownloadBookmarkData:Data?
    var runningStatus:downloadRunningStatus
    let totalSize:Int
    var chuckDownloadData:[ChunkDownloadData]
    var totalDownloaded:Int
    var currentSpeed:Int
    var isNewDownload:Bool
    let userName:String?
    let password:String?
    var isScheduled:Bool
}

protocol FileDownloaderDelegate:class {
    func showLoader()
    func hideLoader()
    func newFileDataCreationFalied()
    func newTempFileCreationFailed()
    func downloadStarted()
    func downloadCompleted()
    func notAbleToWriteToDownloadFile()
    func pauseFailed()
    func downloadFalied(isNonResumable:Bool)
}

final class IDMFileDownloadDataHelper{
    
    weak var delegate:FileDownloaderDelegate?
    var fileDownloadData:FileDownloadDataInfo
    var currentUIData:UIData
    var segmentDownloaders = [IDMSegmentDownloader]()
    let fileHandler = IDMFileHandler()
    var lastDownloadSpeedCheckTime:Date?
    init(delegate:FileDownloaderDelegate, fileDownloadInfo:FileDownloadDataInfo) {
        self.delegate = delegate
        self.fileDownloadData = fileDownloadInfo
        self.currentUIData = UIData(totalDownloaded: fileDownloadInfo.totalDownloaded, speedArray: [0], timeRemaining: Int.max,isRetyringOnError: false )
        self.createDonwloadChunks()
    }
    
    final func startDownloading(shouldForceStartPauseDownload:Bool) {
        if self.fileDownloadData.isNewDownload {
            intiateNewDownload()
        }else if self.fileDownloadData.runningStatus == .paused && shouldForceStartPauseDownload{
            startSegmentDownloads()
        }else if self.fileDownloadData.runningStatus == .running {
            self.startSegmentDownloads()
        }
    }
    
    private func intiateNewDownload(){
        delegate?.showLoader()
        IDMCoreDataHelper.shared.insertNewFileDownloadData(fileDownloadInfo: fileDownloadData) { [weak self]
            (error)
            in
            guard let blockSelf = self
                else{
                    return
            }
            if error != nil {
                blockSelf.delegate?.hideLoader()
                blockSelf.delegate?.newFileDataCreationFalied()
                return
            }
            blockSelf.createTempFileForDownloadAndStart()
        }
    }
    
    private func createTempFileForDownloadAndStart() {
        fileHandler.createTempFileAtLoaction(fileName: self.fileDownloadData.name, directoryLocation: self.fileDownloadData.diskDownloadLocation, fileBookMark: self.fileDownloadData.diskDownloadBookmarkData) {
            [weak self]
            (fileNameOfCreatedTempFile, error)
            in
            guard let blockSelf = self
                else {
                    return
            }
            blockSelf.delegate?.hideLoader()
            if error != nil {
                blockSelf.deleteCurrentInsertedData()
                blockSelf.delegate?.newTempFileCreationFailed()
                return
            }
            if fileNameOfCreatedTempFile != blockSelf.fileDownloadData.name {
                blockSelf.fileDownloadData.name = fileNameOfCreatedTempFile
                blockSelf.saveFileDownloadInfoInDB(completion: { [weak self]
                    (error) in
                    guard let blockSelf = self
                        else{
                            return
                    }
                    if error == nil {
                        if !blockSelf.fileDownloadData.isScheduled{
                            blockSelf.startSegmentDownloads()
                        }
                    }
                })
                return
            }
            if !blockSelf.fileDownloadData.isScheduled{
                blockSelf.startSegmentDownloads()
            }
            
            
        }
    }
    
    
    final func removeTempFileForDownload() -> Bool{
        return self.fileHandler.checkAndRemoveTempFile(fileName: self.fileDownloadData.name, containingDirectory: self.fileDownloadData.diskDownloadLocation, fileBookMarkData: self.fileDownloadData.diskDownloadBookmarkData)
    }
    
    private func deleteCurrentInsertedData() {
        IDMCoreDataHelper.shared.deleteDataForFileInfo(fileDownloadInfo: self.fileDownloadData){_ in 
            //do nothing
        }
    }
    
    private func createChunksAndStartDownload() {
        createDonwloadChunks()
        startSegmentDownloads()
    }
    
    private func createDonwloadChunks() {
        for segment in self.fileDownloadData.chuckDownloadData {
            let segmentDownloader = IDMSegmentDownloader(data: segment, delegate: self)
            self.segmentDownloaders.append(segmentDownloader)
        }
    }
    
    private func startSegmentDownloads() {
        self.fileDownloadData.runningStatus = .running
        lastDownloadSpeedCheckTime = Date()
        for segmentDownloader in segmentDownloaders {
            segmentDownloader.start()
        }
          self.delegate?.downloadStarted()
    }
    
    @objc func pauseDownload(completion:@escaping (_ error:NSError?) -> ()) {
        saveStateOfChunks(chunkIndex: 0, completion: completion)
    }
    
    final func cancelDownloading( completion:@escaping (_ error:NSError?) -> ()) {
        if self.fileDownloadData.runningStatus == .completed{
            completion(nil)
            return
        }
        cancelDownloadInChunk(chunkIndex: 0, completion: completion)
    }
    
    final func clearAllDataAndReStart() {
        self.fileDownloadData.startTimeStamp = Date().timeIntervalSince1970
        self.fileDownloadData.runningStatus = downloadRunningStatus.running
        self.fileDownloadData.totalDownloaded = 0
        self.fileDownloadData.currentSpeed = 0
        self.fileDownloadData.isNewDownload = true
        self.currentUIData = UIData(totalDownloaded:  self.fileDownloadData.totalDownloaded, speedArray: [0], timeRemaining: Int.max,isRetyringOnError: false )
        var newChunkDataArray = [ChunkDownloadData]()
        for chunkData in self.fileDownloadData.chuckDownloadData {
            let newChunkData = ChunkDownloadData(uniqueID: chunkData.uniqueID, startByte: chunkData.startByte, endByte: chunkData.endByte, totalDownloaded: 0, downloadURL: chunkData.downloadURL, isCompleted: false, userName:chunkData.userName, password:chunkData.password)
            newChunkDataArray.append(newChunkData)
        }
        self.fileDownloadData.chuckDownloadData = newChunkDataArray
        self.segmentDownloaders.removeAll()
        self.createDonwloadChunks()
        self.createTempFileForDownloadAndStart()
    }
    
    //cancle all dowonloads recursivly
    private func cancelDownloadInChunk(chunkIndex:Int, completion:@escaping (_ error:NSError?) -> ()) {
        if chunkIndex >= self.segmentDownloaders.count {
            completion(nil)
            return
        }
        
        self.segmentDownloaders[chunkIndex].cancelDownloading {
            [weak self]
            in
            guard let blockSelf = self
                else{
                    return
            }
            blockSelf.cancelDownloadInChunk(chunkIndex: chunkIndex + 1, completion: completion)
        }
    }
    
    //start recursive save
    private func saveStateOfChunks(chunkIndex:Int, completion:@escaping (_ error:NSError?) -> ()) {
        if chunkIndex >= self.segmentDownloaders.count {
            self.fileDownloadData.runningStatus = .paused
            self.saveFileDownloadInfoInDB(completion: completion)
            return
        }
        
        self.segmentDownloaders[chunkIndex].saveSegmentResumeData {
            [weak self]
            (error)
            in
            guard let blockSelf = self
                else{
                    return
            }
            if (error == nil){
                blockSelf.saveStateOfChunks(chunkIndex: chunkIndex + 1, completion: completion)
            }else {
                blockSelf.fileDownloadData.runningStatus = .failed
                blockSelf.saveFileDownloadInfoInDB(completion: { (error) in
                })
            }
        }
    }
    
    func saveFileDownloadInfoInDB(completion:@escaping (_ error:NSError?) -> ()) {
        IDMCoreDataHelper.shared.updateDBWithFileDownloadInfo(fileDownloadInfo: self.fileDownloadData) { [weak self]
            (error) in
            guard let _ = self
                else{
                    return
            }
            
            if error != nil {
                completion(error! as NSError)
                return
            }
            completion(nil)
        }
    }
    
    final func resumeDownload(completion:@escaping (_ error:NSError?) -> ()) {
        lastDownloadSpeedCheckTime = Date()
        resumeDownloadForChunk(chunkIndex: 0, completion: completion)
    }
    
    private func resumeDownloadForChunk(chunkIndex:Int,completion:@escaping (_ error:NSError?) -> ()){
        if chunkIndex >= self.segmentDownloaders.count {
            self.fileDownloadData.runningStatus = .running
            self.saveFileDownloadInfoInDB(completion: completion)
            return
        }
        
        self.segmentDownloaders[chunkIndex].resumeDownload {
            [weak self]
            in
            guard let blockSelf = self
                else{
                    return
            }
            blockSelf.resumeDownloadForChunk(chunkIndex: chunkIndex + 1, completion: completion)
        }
        
    }
    
    final func markDownloadFailed() {
        self.fileDownloadData.runningStatus = .failed
        _ = self.removeTempFileForDownload()
        self.saveFileDownloadInfoInDB { (error) in
            //do nothing with error
        }
    }
    
    fileprivate func updateFileExtension() -> Bool{
        let fileExtension = URL(string:self.fileDownloadData.downloadURL)!.pathExtension
        if self.fileHandler.setFileExtension(fileName: self.fileDownloadData.name, containingDirectory: self.fileDownloadData.diskDownloadLocation, newExtension: fileExtension, fileBookMarkData: self.fileDownloadData.diskDownloadBookmarkData){
            return true
            
        }else {
            return false
        }
    }
    
    fileprivate func fireLocalNotification() {
        let title = "Download completed"
        let informativeText = "File - \(self.fileDownloadData.name) is downloaded"
        let userInfo = ["downloadID":self.fileDownloadData.uniqueID]
        IDMLocalNotificationHelper.shared.showNotification(title: title, infomativeText: informativeText, userInfo: userInfo)
    }
}

extension IDMFileDownloadDataHelper:SegmentDownloaderDelegate {
    
    func didWriteData() {
        let currentTotalDownloaded = self.fileDownloadData.totalDownloaded
        var newTotalDownloaded = 0
        var isRetryingOnError = false
        var newChunkData = [ChunkDownloadData]()
        for segmentDownloader in self.segmentDownloaders {
            newChunkData.append(segmentDownloader.downloadData)
            newTotalDownloaded = newTotalDownloaded + segmentDownloader.downloadData.totalDownloaded
            if segmentDownloader.isRetryingDownloadStart {
                isRetryingOnError = true
            }
        }
        self.fileDownloadData.chuckDownloadData = newChunkData
        
        guard newTotalDownloaded < self.fileDownloadData.totalSize
            else{
            return
        }
        
        guard newTotalDownloaded > currentTotalDownloaded else {
             Swift.print("new total is less")
            return
        }
        
        guard Date().timeIntervalSince(lastDownloadSpeedCheckTime!) > 0
            else {
                return
        }
        
        let timeSinceLastDownload = Date().timeIntervalSince(lastDownloadSpeedCheckTime!)
        lastDownloadSpeedCheckTime = Date()
        let currentSpeed = Double(newTotalDownloaded - currentTotalDownloaded)/Double(timeSinceLastDownload) //bytes per second
        self.fileDownloadData.totalDownloaded = newTotalDownloaded
        var timeRemaining = Int.max
        if (currentSpeed != 0){
            if self.currentUIData.speedArray.count <= 200 {
                self.currentUIData.speedArray.append(currentSpeed)
            }else {
                var newAarray = self.currentUIData.speedArray[1..<self.currentUIData.speedArray.count]
                newAarray.append(currentSpeed)
                self.currentUIData.speedArray = Array(newAarray)
            }
            timeRemaining = (self.fileDownloadData.totalSize - self.fileDownloadData.totalDownloaded)/Int(self.currentUIData.speedArray.average)
        }
    
        
        
        self.currentUIData = UIData(totalDownloaded: self.fileDownloadData.totalDownloaded,speedArray: self.currentUIData.speedArray,timeRemaining: timeRemaining, isRetyringOnError:isRetryingOnError)
        self.fileHandler.updateProgressBarInFinder(fileName: self.fileDownloadData.name, containingDirectory: self.fileDownloadData.diskDownloadLocation, fileBookMarkData: self.fileDownloadData.diskDownloadBookmarkData, fraction: Double(self.fileDownloadData.totalDownloaded)/Double(self.fileDownloadData.totalSize))
    
    }
    
    func didCompletedDownload(){
        
        var isAllSegmentsCompletedDownload = true
        for segments in self.segmentDownloaders {
            if !segments.downloadData.isCompleted {
                isAllSegmentsCompletedDownload = false
                break
            }
        }
        
        if isAllSegmentsCompletedDownload {
            if self.updateFileExtension() {
                self.fileDownloadData.runningStatus = .completed
                self.fileDownloadData.endTimeStamp = Date().timeIntervalSince1970
                self.saveFileDownloadInfoInDB(completion: { [weak self]
                    (error)
                    in
                    guard let blockSelf = self
                        else{
                            return
                    }
                    if error == nil {
                       
                        blockSelf.delegate?.downloadCompleted()
                        blockSelf.fireLocalNotification()
                    }else {
                        blockSelf.markDownloadFailed()
                    }
                    
                })
            }
        }
    }
    
    func writeDataToOffset(data:Data, offset:Int) -> Bool {
        return fileHandler.writeDownloadedDataToFile(data: data, downloadFileName: self.fileDownloadData.name, directoryLocation: self.fileDownloadData.diskDownloadLocation, fileBookMark: self.fileDownloadData.diskDownloadBookmarkData, atOffset: UInt64(offset))
    }
    
    func isResumeSupported() -> Bool {
        return self.fileDownloadData.isResumeSupported
    }
    
    func updateDBWithChunkDownloadData(data:ChunkDownloadData, compeletion:@escaping (_ error:Error?)-> ()){
        IDMCoreDataHelper.shared.updateDBWithChunkDownloadData(chunkDownloadInfo: data) { (error) in
           compeletion(error)
        }
    }
    
    func chunkDownloadFailed() {
        self.markDownloadFailed()
    }
    
    func isRetrying(){
        self.currentUIData.isRetyringOnError = true
    }
    
    func downloadFailedForChunk(isNonResumable:Bool) {
        if self.fileDownloadData.runningStatus != .failed{
            self.delegate?.downloadFalied(isNonResumable: isNonResumable)
        }
        self.markDownloadFailed()
       
    }
}
