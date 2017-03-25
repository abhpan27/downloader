//
//  IDMDownloadHeaderFetchHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation
struct DownloadProbeError {
    static let errorDomain = "DownloadProbeError"
    static let codeNoInternet = 1
    static let codeHeaderNotFound = 2
    static let contentLengthNotFoundCode = 3
    static let noInternet = NSError(domain: errorDomain, code: codeNoInternet, userInfo: nil)
    static let headerNotFound = NSError(domain: errorDomain, code: codeHeaderNotFound, userInfo: nil)
    static let contentLengthNotFound = NSError(domain: errorDomain, code: contentLengthNotFoundCode, userInfo: nil)
}

final class IDMDownloadHeaderFetchHelper{
   
    final func fetchHeaderDataForDownloadURL(downloadLink:String, completion:@escaping ((_ error:NSError?, _ canBreakIntoSegments:Bool, _ contentLenght:Int) -> Void)) {
        //check if connected to internet
        if !IDMReachability.isConnectedToInternet(){
             completion(DownloadProbeError.noInternet, false, 0)
             return
        }
        
        let downloadURL = URL(string: downloadLink)!
        var urlRequestForDownload = URLRequest(url: downloadURL)
        urlRequestForDownload.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: urlRequestForDownload) { [weak self]
            (data, urlResponse, error) in
            guard let blockSelf = self
                else{
                    return
            }
            if error != nil {
                completion((error as! NSError), false, 0)
                return
            }
            guard let headerDictonary = (urlResponse as? HTTPURLResponse)?.allHeaderFields as? [String : Any]
                else{
                    completion(DownloadProbeError.headerNotFound, false, 0)
                    return
            }
            blockSelf.parseHeaderFieldFromIntialPoll(headerField: headerDictonary, completion:completion)
   
        }.resume()
    }
    
    private func parseHeaderFieldFromIntialPoll(headerField:[String:Any], completion:@escaping ((_ error:NSError?, _ canBreakIntoSegments:Bool, _ contentLenght:Int) -> Void)){
        Swift.print("header probe result :\(headerField)")
        let canBreakIntoSegments = isSegmentedDownloadSupported(probeHeader: headerField)
        guard let contentLengthString = headerField["Content-Length"] as? String
            else{
                completion(DownloadProbeError.contentLengthNotFound, false, 0)
                return
        }
        guard let contentLength = Int(contentLengthString)
            else{
                completion(DownloadProbeError.contentLengthNotFound, false, 0)
                return
        }
        completion(nil, canBreakIntoSegments, contentLength)
    }
    
    
    private func isSegmentedDownloadSupported(probeHeader:[String:Any]) -> Bool {
        let isEtagAvailable = (probeHeader["Etag"] != nil)
        let isLastModifiedAvaible = (probeHeader["Last-Modified"] != nil)
        let isByteRangeSupported = (probeHeader["Accept-Ranges"] != nil)
        if !isByteRangeSupported {
            return false
        }
        
        if isEtagAvailable{
            return true
        }
        
        if isLastModifiedAvaible{
            return true
        }
        
        return false
    }
}
