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
    let downloadURL:String
    var isCompleted:Bool
}

protocol SegmentDownloaderDelegate:class {
    func isResumeSupported() -> Bool
    func didWriteData()
    func didCompletedDownload()
    func updateDBWithChunkDownloadData(data:ChunkDownloadData, compeletion:@escaping (_ error:Error?)-> ())
    func writeDataToOffset(data:Data, offset:Int) -> Bool
    func isRetrying()
    func downloadFailedForChunk(isNonResumable:Bool)
}

final class IDMSegmentDownloader:NSObject, URLSessionDataDelegate{
    
    var downloadData:ChunkDownloadData
    weak var delegate:SegmentDownloaderDelegate?
    var session:URLSession?
    var downloadTask:URLSessionDataTask?
    var sessionInvalidateTaskCompletion:((_ error:NSError?) -> ())?
    var isRetryingDownloadStart = false {
        didSet {
            delegate?.isRetrying()
        }
    }
    
    init(data:ChunkDownloadData, delegate:SegmentDownloaderDelegate){
        self.downloadData = data
        self.delegate = delegate
    }
    
    private func setUpSession() {
        self.session?.invalidateAndCancel()
        let urlConfigurationForDownload = URLSessionConfiguration.default
        urlConfigurationForDownload.httpMaximumConnectionsPerHost = 15
        urlConfigurationForDownload.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlConfigurationForDownload.urlCache = nil
        session = URLSession(configuration: urlConfigurationForDownload, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    final func start() {
        guard !self.downloadData.isCompleted
            else{
                return
        }
        setUpSession()
        downloadTask = session!.dataTask(with: getURLRequestForDownloadTask())
        downloadTask!.resume()
    }
    
    private func getURLRequestForDownloadTask() -> URLRequest {
        var urlRequestForChunkDownload = URLRequest(url: URL(string: downloadData.downloadURL)!)
        urlRequestForChunkDownload.addValue("bytes=\(getStartByteRange())-\(self.downloadData.endByte)", forHTTPHeaderField: "Range")
        Swift.print("UUID :\(self.downloadData.uniqueID) starting download from bytes=\(getStartByteRange())-\(self.downloadData.endByte)")
        return urlRequestForChunkDownload
    }
    
    private func getStartByteRange() -> Int {
        let currentOffset = self.downloadData.startByte +  self.downloadData.totalDownloaded
        return currentOffset
    }
    
    final func saveSegmentResumeData(completion:@escaping (_ error:NSError?) -> ()){
        self.downloadTask?.cancel()
        self.session?.invalidateAndCancel()
        self.sessionInvalidateTaskCompletion = completion
    }
    
    final func resumeDownload(completion:@escaping () -> ()) {
        self.start()
        completion()
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        if error == nil {
            self.downloadData.isCompleted = true
            self.delegate?.didCompletedDownload()
            return
        }
        
        if  (error as! NSError).domain == NSURLErrorDomain && (error as! NSError).code == NSURLErrorCancelled{
            return
        }
        
        guard (!isRetryingDownloadStart) else {
            return
        }
        
        guard delegate!.isResumeSupported() else {
            chunkDownloadFailed(isNonResumable: true)
            return
        }
        
        self.isRetryingDownloadStart = true
        self.retryDownloading()
        self.delegate?.isRetrying()

    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?){
        guard let completion = self.sessionInvalidateTaskCompletion
            else{
                return
        }
        Swift.print("UUID :\(self.downloadData.uniqueID) paused download at :\(self.downloadData.totalDownloaded)")
        self.delegate?.updateDBWithChunkDownloadData(data: self.downloadData, compeletion: { [weak self]
            (error) in
            guard let blockSelf = self
                else {
                    return
            }
            runInMainThread {
                if error == nil {
                Swift.print("UUID :\(blockSelf.downloadData.uniqueID) after savinf in DB download at :\(blockSelf.downloadData.totalDownloaded)")
                    completion(nil)
                }else {
                    completion(NSError(domain: ChunkDownloadError.errorDomain, code: ChunkDownloadError.pauseFailed, userInfo: nil))
                }
            }
        })
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void){
        completionHandler(URLSession.ResponseDisposition.allow)
        self.sessionInvalidateTaskCompletion = nil
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        let offsetToWrite = self.downloadData.startByte + self.downloadData.totalDownloaded
        if delegate!.writeDataToOffset(data: data, offset: offsetToWrite){
            let bytesWritten = (data as NSData).length
            Swift.print("UUID :\(self.downloadData.uniqueID) writing data of lenght :\(bytesWritten) at offset :\(offsetToWrite)")
            self.downloadData.totalDownloaded = Int(bytesWritten) + self.downloadData.totalDownloaded
            self.delegate?.didWriteData()
        }else {
            chunkDownloadFailed(isNonResumable: false)
        }
    }
    
    private func retryDownloading() {
        if !isRetryingDownloadStart {
            return
        }
        if IDMReachability.isConnectedToInternet() {
            self.setUpSession()
            self.start()
            isRetryingDownloadStart = false
            return
        }
        let retryInterval = 3
        runAfterDelay(delay: Double(retryInterval)) {
            self.retryDownloading()
        }
    }
    
    private func chunkDownloadFailed(isNonResumable:Bool) {
        self.downloadTask?.cancel()
        self.session?.invalidateAndCancel()
        self.delegate!.downloadFailedForChunk(isNonResumable: isNonResumable)
    }
    
}
