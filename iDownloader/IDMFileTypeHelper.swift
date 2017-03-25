//
//  IDMFileTypeHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

internal enum fileTypes:String{
    case video,
    document,
    picture,
    application,
    compressed,
    other
    
    var nameForType:String {
        switch self {
        case .video:
            return "Video"
        case .document:
            return "Document"
        case .picture:
            return "Image"
        case .application:
            return "Executable"
        case .compressed:
            return "Compressed"
        case .other:
            return "Unknown file type"
        }
    }
    
    var imageForFileType:NSImage{
        switch self {
        case .video:
            return NSImage(named: "videofile")!
        case .document:
            return NSImage(named: "documentfile")!
        case .picture:
            return NSImage(named: "imagefile")!
        case .application:
            return NSImage(named: "executablefile")!
        case .compressed:
            return NSImage(named: "compressedfile")!
        case .other:
            return NSImage(named: "otherfile")!
        }
    }
    
}

final class IDMFileTypeHelper{
    
    let videoFileExtensions = ["webm", "mkv", "flv", "vob", "ogv", "ogg", "drc", "avi", "mov","qt", "wmv", "yuv", "rm",
    "rmvb", "amv", "mp4", "m4p", "mpg", "mp2", "mpeg", "mpe", "mpv", "m4v", "svi", "3gp"]
    
    let documentsFileFormats = ["doc" ,"docx", "odt", "pdf", "rtf", "tex", "txt", "wks" ,"wps", "wpd"]
    
    let compressedFileExtensions = ["7z", "arj", "deb", "pkg", "rar", "rpm", "tar.gz",".z", "zip"]
    
    let imageFileFormats = ["ai", "bmp", "gif", "ico", "jpeg", "jpg", "png", "ps", "psd", "svg", "tif", "tiff"]
    
    let applicationFileFormats = ["apk", "bat", "bin", "cgi", "pl", "com", "exe", "gadget", "jar", "wsf", "dmg", "app"]
    
    final func getFileType(fileExtension:String) -> fileTypes{
        if videoFileExtensions.contains(fileExtension){
            return fileTypes.video
        }else if documentsFileFormats.contains(fileExtension) {
            return fileTypes.document
        }else if compressedFileExtensions.contains(fileExtension) {
            return fileTypes.compressed
        }else if imageFileFormats.contains(fileExtension) {
            return fileTypes.picture
        }else if applicationFileFormats.contains(fileExtension) {
            return fileTypes.application
        }
        
        return fileTypes.other
        
    }
    
}
