//
//  IDMFileManager.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

final class IDMFileManager{
    
    static let shared = IDMFileManager()
    
    var defaultDownloadURL:URL {
        let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.resolvingSymlinksInPath()
        return url
    }
}
