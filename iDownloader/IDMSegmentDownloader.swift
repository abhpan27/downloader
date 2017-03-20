//
//  IDMSegmentDownloader.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation

struct ChunkDownloadData {
    let uniqueID:String
    let startByte:Int
    let endByte:Int
    var totalDownloaded:Int
    var resumeData:Data?
    let downloadURL:String
}

protocol SegmentDownloaderDelegate:class {
    func isResumeSupported() -> Bool
    func didWriteData()
}

final class IDMSegmentDownloader:NSObject, URLSessionDownloadDelegate{
    
    var donwloadData:ChunkDownloadData
    weak var delegate:SegmentDownloaderDelegate?
    var session:URLSession?
    
    init(data:ChunkDownloadData, delegate:SegmentDownloaderDelegate){
        self.donwloadData = data
        self.delegate = delegate
    }
    
    final func start() {
        Swift.print("start download for url :\(donwloadData.downloadURL) from :\(donwloadData.startByte) to \(donwloadData.endByte)")
        let urlConfigurationForDownload = URLSessionConfiguration.default
        urlConfigurationForDownload.httpMaximumConnectionsPerHost = 15
        session = URLSession(configuration: urlConfigurationForDownload, delegate: self, delegateQueue: OperationQueue.main)
        var urlRequestForChunkDownload = URLRequest(url: URL(string: donwloadData.downloadURL)!)
        if self.delegate!.isResumeSupported() {
            urlRequestForChunkDownload.addValue("bytes=\(self.donwloadData.startByte)-\(self.donwloadData.endByte)", forHTTPHeaderField: "Range")
        }
        let downloadTask = session!.downloadTask(with: urlRequestForChunkDownload)
        downloadTask.resume()
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        self.donwloadData.totalDownloaded = Int(totalBytesWritten)
        self.delegate?.didWriteData()
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        if let data = (error as? NSError)?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data{
            self.donwloadData.resumeData = data
            self.session?.downloadTask(withResumeData: data).resume()
        }
    }

}
