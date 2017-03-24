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
    let startTimeStamp:Double
    let endTimeStamp:Double
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
    func newFileDownloadCreationSuccess()
    func downloadCompleted()
    func notAbleToWriteToDownloadFile()
    func pauseFailed()
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
        self.currentUIData = UIData(totalDownloaded: fileDownloadInfo.totalDownloaded, speed: 0, timeRemaining: Int.max)
    }
    
    final func startDownloading() {
        if self.fileDownloadData.isNewDownload {
            intiateNewDownload()
        }else if self.fileDownloadData.runningStatus == .paused{
            createDonwloadChunksAndStartFetchingData()
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
                        blockSelf.createDonwloadChunksAndStartFetchingData()
                    }
                })
                return
            }
             blockSelf.createDonwloadChunksAndStartFetchingData()
            
        }
    }
    
    private func deleteCurrentInsertedData() {
        IDMCoreDataHelper.shared.deleteFileData(fileData: self.fileDownloadData)
    }
    
    private func createDonwloadChunksAndStartFetchingData() {
        lastDownloadSpeedCheckTime = Date()
        for segment in self.fileDownloadData.chuckDownloadData {
            let segmentDownloader = IDMSegmentDownloader(data: segment, delegate: self)
            self.segmentDownloaders.append(segmentDownloader)
            segmentDownloader.start()
        }
        
        self.delegate?.newFileDownloadCreationSuccess()
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
                    //
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
}

extension IDMFileDownloadDataHelper:SegmentDownloaderDelegate {
    
    func didWriteData() {
        let currentTotalDownloaded = self.fileDownloadData.totalDownloaded
        var newTotalDownloaded = 0
        var newChunkData = [ChunkDownloadData]()
        for segmentDownloader in self.segmentDownloaders {
            newChunkData.append(segmentDownloader.donwloadData)
            newTotalDownloaded = newTotalDownloaded + segmentDownloader.donwloadData.totalDownloaded
        }
        
        guard newTotalDownloaded < self.fileDownloadData.totalSize
            else{
            return
        }
        
        guard newTotalDownloaded > currentTotalDownloaded else {
            return
        }
        
        guard Date().timeIntervalSince(lastDownloadSpeedCheckTime!) > 1
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
        
        self.currentUIData = UIData(totalDownloaded: self.fileDownloadData.totalDownloaded,speed: currentSpeed,timeRemaining: timeRemaining)
        
        //update chunk data also
        self.fileDownloadData.chuckDownloadData = newChunkData
    }
    
    func didCompletedDownload(tempFileURL:URL, offset:Int){
        let success = fileHandler.writeDownloadedDataToFile(sourceTempFile: tempFileURL, downloadFileName: self.fileDownloadData.name, directoryLocation: self.fileDownloadData.diskDownloadLocation, fileBookMark: self.fileDownloadData.diskDownloadBookmarkData, atOffset: UInt64(offset))
        if !success {
            //error case should be handled here
            self.fileDownloadData.runningStatus = .failed
            self.saveFileDownloadInfoInDB(completion:  { [weak self]
                (error)
                in
                guard let blockSelf = self
                    else{
                        return
                }
                if error != nil {
                    blockSelf.markDownloadFailed()
                    blockSelf.delegate?.notAbleToWriteToDownloadFile()
                }
            })
            return
        }
        
        var isAllSegmentsCompletedDownload = true
        for segments in self.segmentDownloaders {
            if !segments.donwloadData.isCompleted {
                isAllSegmentsCompletedDownload = false
                break
            }
        }
        
        if isAllSegmentsCompletedDownload {
            self.fileDownloadData.runningStatus = .completed
            self.saveFileDownloadInfoInDB(completion: { [weak self]
                (error)
                in
                guard let blockSelf = self
                    else{
                        return
                }
                if error != nil {
                    blockSelf.delegate?.downloadCompleted()
                }
            })
        }
    }
    
    func isResumeSupported() -> Bool {
        return self.fileDownloadData.isResumeSupported
    }
}
