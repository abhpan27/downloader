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
    
    let tempFileExtension = "RDDownload"
    final func createTempFileAtLoaction(fileName:String, directoryLocation:String, fileBookMark:Data?, completion:((_ finalFileName:String, _ error:NSError?)-> Void)) {
        var fileNameUsed = fileName.stringForFilePath
        var currentPath = directoryLocation + "/\(fileNameUsed).\(tempFileExtension)"
        var indexSubscriptForFileName = 1
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
        if fileBookMark == nil {
            completion(fileName, NSError(domain: FileError.errorDomain, code: FileError.canNotCreateTempFileError, userInfo: nil))
            return
        }
        var isBookMarkDataStale = false
        do {
            if let bookmarkFileURL = try URL(resolvingBookmarkData: fileBookMark!, bookmarkDataIsStale: &isBookMarkDataStale){
                let _ = bookmarkFileURL.startAccessingSecurityScopedResource()
                if !FileManager.default.createFile(atPath: bookmarkFileURL.path + fileNameUsed, contents: nil, attributes: nil){
                    bookmarkFileURL.stopAccessingSecurityScopedResource()
                    completion(fileName,NSError(domain: FileError.errorDomain, code: FileError.canNotCreateTempFileError, userInfo: nil))
                    return
                }
                //sucess case
                bookmarkFileURL.stopAccessingSecurityScopedResource()
                completion(fileNameUsed,nil)
                
            }else {
                completion(fileName,NSError(domain: FileError.errorDomain, code: FileError.canNotCreateTempFileError, userInfo: nil))
            }
           
        }catch {
            Swift.print("error :\(error.localizedDescription)")
            completion(fileName, error as NSError?)
        }
    }
    
    final func writeDownloadedDataToFile(sourceTempFile:URL, downloadFileName:String, directoryLocation:String, fileBookMark:Data?, atOffset:UInt64) -> Bool{

         let downloadURLWithoutBookMark = directoryLocation + "/\(downloadFileName).\(tempFileExtension)"
        Swift.print("offset :\(atOffset)")
        if let fileHandleWithoutBookMark = FileHandle(forUpdatingAtPath:downloadURLWithoutBookMark) {
            if let dataOfFile = self.getMemoryMappedNSDataFromFile(tempFileLocation: sourceTempFile) {
                createAndSaveFileHandleInDifferentThread(fileHandle: fileHandleWithoutBookMark, offset: atOffset, dataOfFile: dataOfFile)
                return true
            }
        }
        
        do {
            var isBookMarkDataStale = false
            if let bookmarkFileURL = try URL(resolvingBookmarkData: fileBookMark!, bookmarkDataIsStale: &isBookMarkDataStale){
                let _ = bookmarkFileURL.startAccessingSecurityScopedResource()
                if let fileHandleWithBookMark = FileHandle(forUpdatingAtPath:bookmarkFileURL.path) {
                    if let dataOfFile = self.getMemoryMappedNSDataFromFile(tempFileLocation: sourceTempFile) {
                        createAndSaveFileHandleInDifferentThread(fileHandle: fileHandleWithBookMark, offset: atOffset, dataOfFile: dataOfFile)
                        return true
                    }else{
                        return false
                    }
                  
                }
                return false
                
            }else {
                return false
            }
            
        }catch {
            Swift.print("error :\(error.localizedDescription)")
            return false
        }
        
    }
    
    private func getMemoryMappedNSDataFromFile(tempFileLocation:URL) -> Data? {
        do {
            let data = try Data.init(contentsOf: tempFileLocation, options: Data.ReadingOptions.alwaysMapped)
            return data
        }catch {
            return nil
        }
        
    }
    
    private func createAndSaveFileHandleInDifferentThread(fileHandle:FileHandle, offset:UInt64, dataOfFile:Data){
        fileHandle.seek(toFileOffset: offset)
        fileHandle.write(dataOfFile)
        Swift.print((dataOfFile as NSData).length)
        fileHandle.closeFile()
//        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
//            fileHandle.seek(toFileOffset: offset)
//            fileHandle.write(dataOfFile)
//            Swift.print((dataOfFile as NSData).length)
//            fileHandle.closeFile()
//        }
    }
    
}

