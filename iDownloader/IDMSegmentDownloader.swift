//
//  IDMSegmentDownloader.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation

struct ChunkDownloadError {
    static let errorDomain = "ChunkDownloadError"
    static let pauseFailed = 1
}
struct ChunkDownloadData {
    let uniqueID:String
    let startByte:Int
    let endByte:Int
    var totalDownloaded:Int
    var resumeData:Data?
    let downloadURL:String
    var isCompleted:Bool
}

protocol SegmentDownloaderDelegate:class {
    func isResumeSupported() -> Bool
    func didWriteData()
    func didCompletedDownload(tempFileURL:URL, offset:Int)
}

final class IDMSegmentDownloader:NSObject, URLSessionDownloadDelegate{
    
    var donwloadData:ChunkDownloadData
    weak var delegate:SegmentDownloaderDelegate?
    var session:URLSession?
    var downloadTask:URLSessionDownloadTask?
    var shouldResumeDownloadOnError:Bool = true
    
    init(data:ChunkDownloadData, delegate:SegmentDownloaderDelegate){
        self.donwloadData = data
        self.delegate = delegate
    }
    
    final func start() {
        let urlConfigurationForDownload = URLSessionConfiguration.default
        urlConfigurationForDownload.httpMaximumConnectionsPerHost = 15
        session = URLSession(configuration: urlConfigurationForDownload, delegate: self, delegateQueue: OperationQueue.main)
        var urlRequestForChunkDownload = URLRequest(url: URL(string: donwloadData.downloadURL)!)
        if self.delegate!.isResumeSupported() {
            urlRequestForChunkDownload.addValue("bytes=\(self.donwloadData.startByte)-\(self.donwloadData.endByte)", forHTTPHeaderField: "Range")
        }
        Swift.print("starting donwload from \(self.donwloadData.startByte) to \(self.donwloadData.endByte) with totalSize: \(self.donwloadData.endByte - self.donwloadData.startByte + 1)")
        downloadTask = session!.downloadTask(with: urlRequestForChunkDownload)
        downloadTask!.resume()
    }
    
    final func saveSegmentResumeData(completion:@escaping (_ error:NSError?) -> ()){
        self.downloadTask?.cancel(byProducingResumeData: { [weak self]
            (data) in
            guard let blockSelf = self
                else {
                    return
            }
            if (data != nil){
                blockSelf.donwloadData.resumeData = data
                Swift.print("paused download")
                blockSelf.shouldResumeDownloadOnError = false
                completion(nil)
                return
            }
            completion(NSError(domain: ChunkDownloadError.errorDomain, code: ChunkDownloadError.pauseFailed, userInfo: nil))
        })
    }
    
    final func resumeDownload(completion:@escaping () -> ()) {
        if let data = self.donwloadData.resumeData{
            self.shouldResumeDownloadOnError = false
            self.downloadTask = self.session?.downloadTask(withResumeData: data)
            self.downloadTask!.resume()
            Swift.print("resumed download")
        }
        completion()
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        self.donwloadData.isCompleted = true
        delegate?.didCompletedDownload(tempFileURL: location, offset: self.donwloadData.startByte)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        self.donwloadData.totalDownloaded = Int(totalBytesWritten)
        self.delegate?.didWriteData()
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        if shouldResumeDownloadOnError, let data = (error as? NSError)?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data{
            self.donwloadData.resumeData = data
            self.downloadTask = self.session?.downloadTask(withResumeData: data)
            self.downloadTask!.resume()
        }
    }
}
