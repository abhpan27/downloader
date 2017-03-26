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
        self.currentUIData = UIData(totalDownloaded: fileDownloadInfo.totalDownloaded, speed: 0, timeRemaining: Int.max,isRetyringOnError: false )
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
            blockSelf.createTempFileForDownload()
        }
    }
    
    private func createTempFileForDownload() {
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
                        blockSelf.startSegmentDownloads()
                    }
                })
                return
            }
             blockSelf.startSegmentDownloads()
            
        }
    }
    
    private func deleteCurrentInsertedData() {
        IDMCoreDataHelper.shared.deleteFileData(fileData: self.fileDownloadData)
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
            timeRemaining = (self.fileDownloadData.totalSize - self.fileDownloadData.totalDownloaded)/Int(currentSpeed)
        }
        
        self.currentUIData = UIData(totalDownloaded: self.fileDownloadData.totalDownloaded,speed: currentSpeed,timeRemaining: timeRemaining, isRetyringOnError:isRetryingOnError)
    
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
        self.markDownloadFailed()
        self.delegate?.downloadFalied(isNonResumable: isNonResumable)
    }
}
