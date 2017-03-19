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
    let resumeData:Data?
    let downloadURL:String
}

protocol SegmentDownloaderDelegate:class {
    
}
final class IDMSegmentDownloader {
    
    var donwloadData:ChunkDownloadData
    weak var delegate:SegmentDownloaderDelegate?
    
    init(data:ChunkDownloadData, delegate:SegmentDownloaderDelegate){
        self.donwloadData = data
        self.delegate = delegate
    }
    
    final func start() {
        
    }
}
