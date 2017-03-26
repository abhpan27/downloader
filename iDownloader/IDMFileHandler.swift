//
//  IDMFileHandler.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 23/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

struct FileError {
    static let errorDomain = "FileError"
    static let canNotCreateTempFileError = 1
    static let canNotWriteToCreatedTempFile = 2
    
}

class IDMFileHandler {
    
    let tempFileExtension = "idmdownload"
    
    
    final func createTempFileAtLoaction(fileName:String, directoryLocation:String, fileBookMark:Data?, completion:((_ finalFileName:String, _ error:NSError?)-> Void)) {
        var fileNameUsed = fileName.stringForFilePath
        var currentPath = directoryLocation + "/\(fileNameUsed).\(tempFileExtension)"
        var indexSubscriptForFileName = 0
        while FileManager.default.fileExists(atPath: currentPath) {
            indexSubscriptForFileName += 1
            fileNameUsed = fileName + "\((indexSubscriptForFileName))"
            currentPath = directoryLocation + "/\(fileNameUsed).\(tempFileExtension)"
        }
        
        if FileManager.default.createFile(atPath: currentPath, contents: nil, attributes: nil){
            //success case
            completion(fileNameUsed, nil)
            return
        }
        
        //try to access it with bookmark.
        guard let bookMarkData = fileBookMark
            else{
                completion(fileName, NSError(domain: FileError.errorDomain, code: FileError.canNotCreateTempFileError, userInfo: nil))
                return
        }

        if let bookmarkDirectoryURL = self.getURLFromBookMarkData(bookmarkData: bookMarkData) {
            _ = bookmarkDirectoryURL.startAccessingSecurityScopedResource()
            let directoryPathWithoutSystemLink = bookmarkDirectoryURL.urlAfterResolvingSytemLink.path
            let filePath = directoryPathWithoutSystemLink + "/\(fileNameUsed).\(tempFileExtension)"
            if FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil){
                completion(fileNameUsed,nil)
            }
        }
        
          completion(fileName,NSError(domain: FileError.errorDomain, code: FileError.canNotCreateTempFileError, userInfo: nil))
        
    }
    
    
    final func writeDownloadedDataToFile(data:Data, downloadFileName:String, directoryLocation:String, fileBookMark:Data?, atOffset:UInt64) -> Bool{

         let downloadURLWithoutBookMark = directoryLocation + "/\(downloadFileName).\(tempFileExtension)"        
        
        if let fileHandleWithoutBookMark = FileHandle(forUpdatingAtPath:downloadURLWithoutBookMark) {
                writeToFile(fileHandle: fileHandleWithoutBookMark, offset: atOffset, dataOfFile: data)
                return true
        }
        
        //try to get it from bookmark data 
        guard let bookMarkData = fileBookMark
            else{
                return false
        }
        
        if let bookmarkDirectoryURL = self.getURLFromBookMarkData(bookmarkData: bookMarkData) {
            _ = bookmarkDirectoryURL.startAccessingSecurityScopedResource()
            let directoryPathWithoutSystemLink = bookmarkDirectoryURL.urlAfterResolvingSytemLink.path
            let filePath = directoryPathWithoutSystemLink + "/\(downloadFileName).\(tempFileExtension)"
            if let fileHandleWithBookMark = FileHandle(forUpdatingAtPath:filePath) {
                    writeToFile(fileHandle: fileHandleWithBookMark, offset: atOffset, dataOfFile: data)
                    return true
            }
        }
        return false
    }
    
    private func writeToFile(fileHandle:FileHandle, offset:UInt64, dataOfFile:Data){
        fileHandle.seek(toFileOffset: offset)
        fileHandle.write(dataOfFile)
        fileHandle.synchronizeFile()
        fileHandle.closeFile()
    }
    
    private func getURLFromBookMarkData(bookmarkData:Data) -> URL? {
        do {
            var isBookMarkDataStale = false
           
            if let bookmarkFileURL = try  URL(resolvingBookmarkData: bookmarkData, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isBookMarkDataStale){
                return bookmarkFileURL
                
            }else {
                return nil
            }
            
        }catch {
            Swift.print("error :\(error.localizedDescription)")
            return nil
        }
    }
    
    final func setFileExtension(fileName:String, containingDirectory:String, newExtension:String, fileBookMarkData:Data?) -> Bool{
        let originalFilePath = containingDirectory + "/\(fileName).\(tempFileExtension)"
        var finalPath = containingDirectory + "/\(fileName).\(newExtension)"
        
        if FileManager.default.isWritableFile(atPath: originalFilePath) {
            do {
                var index = 0
                var usedFileName = fileName
                while FileManager.default.fileExists(atPath: finalPath){
                    index += 1
                    usedFileName = usedFileName + "(\(index))"
                    finalPath = containingDirectory + "/\(usedFileName).\(newExtension)"
                }
                
                try FileManager.default.moveItem(atPath: originalFilePath, toPath: finalPath)
                self.removeFileDownloadedAtrribute(pathURL: URL(string: finalPath.percentEncoded))
                return true
            }catch {
                return false
            }
        }
        
        //try to get it from bookmark data
        guard let bookMarkData = fileBookMarkData
            else{
                return false
        }
        
        if let bookmarkURL = self.getURLFromBookMarkData(bookmarkData: bookMarkData){
            let finalPathURL =  URL(string:finalPath.percentEncoded)!
            _ = bookmarkURL.startAccessingSecurityScopedResource()
            let pathWithoutSystemLink = bookmarkURL.urlAfterResolvingSytemLink
            do {
                try FileManager.default.moveItem(at: pathWithoutSystemLink, to: finalPathURL)
                self.removeFileDownloadedAtrribute(pathURL: URL(string: finalPath.percentEncoded))
                bookmarkURL.stopAccessingSecurityScopedResource()
                return true
            }catch {
                return false
            }
        }
        
        return false
        
    }
    
    final func checkAndRemoveTempFile(fileName:String, containingDirectory:String, fileBookMarkData:Data?) -> Bool{
        let filePath = containingDirectory + "/\(fileName).\(self.tempFileExtension)"
        do {
             try FileManager.default.removeItem(atPath: filePath)
            return true
        }catch {
            
            
            guard let bookMarkData = fileBookMarkData
                else{
                    return false
            }
            
            if let bookmarkURL = self.getURLFromBookMarkData(bookmarkData: bookMarkData){
                _ = bookmarkURL.startAccessingSecurityScopedResource()
                if let pathWithoutSystemLink = URL(string:bookmarkURL.urlAfterResolvingSytemLink.path + "/\(fileName).\(self.tempFileExtension)"){
                    do {
                        try FileManager.default.removeItem(at: pathWithoutSystemLink)
                        bookmarkURL.stopAccessingSecurityScopedResource()
                        return true
                    }catch {
                        return false
                    }
                }
            }
        }
       return false
    }
    
    final func isFileAvailable(fileName:String, containingDirectory:String, fileExtension:String,fileBookMarkData:Data?) -> URL?{
        
        if let bookMarkData = fileBookMarkData{
            if let bookmarkURL = self.getURLFromBookMarkData(bookmarkData: bookMarkData){
                _ = bookmarkURL.startAccessingSecurityScopedResource()
                let pathWithoutSystemLink = bookmarkURL.urlAfterResolvingSytemLink.path + "/\(fileName).\(fileExtension)"
                if FileManager.default.fileExists(atPath: pathWithoutSystemLink){
                    return URL(fileURLWithPath: pathWithoutSystemLink, relativeTo: Bundle.main.bundleURL)
                }
            }
        }
        
        
        let originalFilePath = containingDirectory + "/\(fileName).\( fileExtension )"
        if FileManager.default.fileExists(atPath: originalFilePath) {
            return URL(fileURLWithPath: originalFilePath, relativeTo: Bundle.main.bundleURL)
        }
        
       
        
        return nil
    }
    
    final func updateProgressBarInFinder(fileName:String, containingDirectory:String,fileBookMarkData:Data?, fraction:Double) {
        if let bookMarkData = fileBookMarkData{
            if let bookmarkURL = self.getURLFromBookMarkData(bookmarkData: bookMarkData){
                _ = bookmarkURL.startAccessingSecurityScopedResource()
                let pathWithoutSystemLink = bookmarkURL.urlAfterResolvingSytemLink.path + "/\(fileName).\(self.tempFileExtension)"
                if let url = URL(string:pathWithoutSystemLink.percentEncoded) {
                    setFileDownloadedAttribute(url: url, fraction: fraction)
                }
                bookmarkURL.stopAccessingSecurityScopedResource()
                return
            }
        }
        
        
        let originalFilePath = containingDirectory + "/\(fileName).\( self.tempFileExtension )"
        if FileManager.default.fileExists(atPath: originalFilePath) {
            if let url = URL(string:originalFilePath.percentEncoded)  {
                setFileDownloadedAttribute(url: url, fraction: fraction)
            }
            
        }
    }
    
    private func setFileDownloadedAttribute(url:URL, fraction:Double) {
        let data = String(format:"%.1f bytes/S", fraction).data(using: String.Encoding.ascii)
        do {
            try url.setExtendedAttribute(data: data!, forName: "com.apple.progress.fractionCompleted")
            try FileManager.default.setAttributes([FileAttributeKey.creationDate : NSDate(string:"1984-01-24 08:00:00 +0000")], ofItemAtPath: url.path)
        }catch {
      }
    }
    
    private func removeFileDownloadedAtrribute(pathURL:URL?) {
        guard let url = pathURL
            else {
                return
        }
        do {
            try url.removeExtendedAttribute(forName: "com.apple.progress.fractionCompleted")
            try FileManager.default.setAttributes([FileAttributeKey.creationDate : Date()], ofItemAtPath: url.path)
        }catch {
        }
    }
}

