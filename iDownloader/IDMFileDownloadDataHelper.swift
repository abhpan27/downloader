//
//  IDMFileDownloadDataHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation

enum downloadRunningStatus:String{
    case running = "running", paused = "paused"
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
    let runningStatus:downloadRunningStatus
    let totalSize:Int
    let chuckDownloadData:[ChunkDownloadData]
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
    
}

extension IDMFileDownloadDataHelper:SegmentDownloaderDelegate {
    
    func didWriteData() {
        let currentTotalDownloaded = self.fileDownloadData.totalDownloaded
        var newTotalDownloaded = 0
        for segmentDownloader in self.segmentDownloaders {
            newTotalDownloaded = newTotalDownloaded + segmentDownloader.donwloadData.totalDownloaded
        }
        
        guard newTotalDownloaded < self.fileDownloadData.totalSize
            else{
            return
        }
        
        let timeSinceLastDownload = Date().timeIntervalSince(lastDownloadSpeedCheckTime!) > 1 ? Date().timeIntervalSince(lastDownloadSpeedCheckTime!) : 1
        lastDownloadSpeedCheckTime = Date()
        let currentSpeed = (newTotalDownloaded - currentTotalDownloaded)/Int(timeSinceLastDownload) //bytes per second
        self.fileDownloadData.totalDownloaded = newTotalDownloaded
        let timeRemaining = (self.fileDownloadData.totalSize - self.fileDownloadData.totalDownloaded)/currentSpeed
        
        self.currentUIData = UIData(totalDownloaded: self.fileDownloadData.totalDownloaded,speed: currentSpeed,timeRemaining: timeRemaining)
    }
    
    func isResumeSupported() -> Bool {
        return self.fileDownloadData.isResumeSupported
    }
}
