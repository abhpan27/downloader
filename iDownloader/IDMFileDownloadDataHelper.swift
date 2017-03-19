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
    func newFileDataCreationFalied()
    func newFileDownloadCreationSuccess()
    
}

final class IDMFileDownloadDataHelper:SegmentDownloaderDelegate{
    
    weak var delegate:FileDownloaderDelegate?
    var fileDownloadData:FileDownloadDataInfo
    var segmentDownloaders = [IDMSegmentDownloader]()
    init(delegate:FileDownloaderDelegate, fileDownloadInfo:FileDownloadDataInfo) {
        self.delegate = delegate
        self.fileDownloadData = fileDownloadInfo
    }
    
    final func startDownloading() {
        if self.fileDownloadData.isNewDownload {
            intiateNewDownload()
        }else if self.fileDownloadData.runningStatus == .running{
            createDonwloadChunksAndStartFetchingData()
        }
    }
    
    private func intiateNewDownload(){
        IDMCoreDataHelper.shared.insertNewFileDownloadData(fileDownloadInfo: fileDownloadData) { [weak self]
            (error)
            in
            guard let blockSelf = self
                else{
                    return
            }
            if error != nil {
                blockSelf.delegate?.newFileDataCreationFalied()
                return
            }
            blockSelf.createDonwloadChunksAndStartFetchingData()
        }
    }
    
    private func createDonwloadChunksAndStartFetchingData() {
        for segment in self.fileDownloadData.chuckDownloadData {
            let segmentDownloader = IDMSegmentDownloader(data: segment, delegate: self)
            self.segmentDownloaders.append(segmentDownloader)
            segmentDownloader.start()
        }
    }
    
}
