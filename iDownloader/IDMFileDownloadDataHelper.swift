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
    let name:String
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
    func newFileDownloadCreationSuccess()
}

final class IDMFileDownloadDataHelper{
    
    weak var delegate:FileDownloaderDelegate?
    var fileDownloadData:FileDownloadDataInfo
    var currentUIData:UIData
    var segmentDownloaders = [IDMSegmentDownloader]()
    var lastDownloadSpeedCheckTime:Date?
    init(delegate:FileDownloaderDelegate, fileDownloadInfo:FileDownloadDataInfo) {
        self.delegate = delegate
        self.fileDownloadData = fileDownloadInfo
        self.currentUIData = UIData(totalDownloaded: fileDownloadInfo.totalDownloaded, speed: 0, timeRemaining: Int.max)
    }
    
    final func startDownloading() {
        if self.fileDownloadData.isNewDownload {
            intiateNewDownload()
        }else if self.fileDownloadData.runningStatus == .running{
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
            blockSelf.delegate?.hideLoader()
            if error != nil {
                blockSelf.delegate?.newFileDataCreationFalied()
                return
            }
            blockSelf.createDonwloadChunksAndStartFetchingData()
        }
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
            in
            guard let blockSelf = self
                else{
                    return
            }
            blockSelf.saveStateOfChunks(chunkIndex: chunkIndex + 1, completion: completion)
        }
    }
    
    private func saveFileDownloadInfoInDB(completion:@escaping (_ error:NSError?) -> ()) {
        IDMCoreDataHelper.shared.updateDBWithFileDownloadInfo(fileDownloadInfo: self.fileDownloadData) { [weak self]
            (error) in
            guard let _ = self
                else{
                    return
            }
            
            if error != nil {
                completion(error! as NSError)
            }
            runInMainThread {
                completion(nil)
            }
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
    
    func isResumeSupported() -> Bool {
        return self.fileDownloadData.isResumeSupported
    }
}