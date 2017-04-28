//
//  IDMCoreDataHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

struct CoreDataErrors {
    static let domain = "coreDataErrors"
    static let nothingFound = 1
}

final class IDMCoreDataHelper {
    
    static let shared = IDMCoreDataHelper()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iDownloader")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    final func insertNewFileDownloadData(fileDownloadInfo:FileDownloadDataInfo, completion:@escaping (_ error:Error?)-> ()){
        persistentContainer.performBackgroundTask { (context) in
            let fileDownloadData =  FileDownloadData(context: context)
            fileDownloadData.fileDownloadID = fileDownloadInfo.uniqueID
            fileDownloadData.fileName = fileDownloadInfo.name
            fileDownloadData.fileDownloadURL = fileDownloadInfo.downloadURL
            fileDownloadData.totalSize = NSNumber(value:fileDownloadInfo.totalSize)
            fileDownloadData.fileType = fileDownloadInfo.type.rawValue
            fileDownloadData.totalDownloaded = NSNumber(value:fileDownloadInfo.totalDownloaded)
            fileDownloadData.isResumable = fileDownloadInfo.isResumeSupported
            fileDownloadData.diskDownloadBookMark = fileDownloadInfo.diskDownloadBookmarkData as NSData?
            fileDownloadData.diskDownloadURL = fileDownloadInfo.diskDownloadLocation
            fileDownloadData.runningStatus = fileDownloadInfo.runningStatus.rawValue
            fileDownloadData.downloadStartTime = fileDownloadInfo.startTimeStamp
            fileDownloadData.downloadEndTime = fileDownloadInfo.endTimeStamp
            //encrypt it
            fileDownloadData.username = fileDownloadInfo.userName?.encrypted
            fileDownloadData.password = fileDownloadInfo.password?.encrypted
            fileDownloadData.isScheduled = fileDownloadInfo.isScheduled
            var segmentsSet = Set<SegmentDownloadData>()
            for chunkDownloadInfo in fileDownloadInfo.chuckDownloadData {
                let segmentData = SegmentDownloadData(context: context)
                segmentData.startByte = NSNumber(value:chunkDownloadInfo.startByte)
                segmentData.endByte = NSNumber(value:chunkDownloadInfo.endByte)
                segmentData.segmentID = chunkDownloadInfo.uniqueID
                segmentData.totalDownloaded = NSNumber(value:chunkDownloadInfo.totalDownloaded)
                segmentsSet.insert(segmentData)
            }
            fileDownloadData.segments = segmentsSet as NSSet
            do {
                try context.save()
                completion(nil)
            }catch {
                Swift.print("saving falied")
                completion(error)
            }
            
        }
       
    }
    
    final func updateDBWithChunkDownloadData(chunkDownloadInfo:ChunkDownloadData, completion:@escaping (_ error:Error?)-> ())
    {
        persistentContainer.performBackgroundTask { (context) in
            let segmentFecthRequest: NSFetchRequest<NSFetchRequestResult> = SegmentDownloadData.fetchRequest()
            segmentFecthRequest.predicate = NSPredicate(format: "segmentID == %@", chunkDownloadInfo.uniqueID)
            do {
                let segmentDownloadArray =  try context.fetch(segmentFecthRequest)
                guard let segmentDownloadData = segmentDownloadArray.last as? SegmentDownloadData
                    else {
                        
                        completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil))
                        return
                }
                segmentDownloadData.startByte = NSNumber(value:chunkDownloadInfo.startByte)
                segmentDownloadData.endByte = NSNumber(value:chunkDownloadInfo.endByte)
                segmentDownloadData.totalDownloaded = NSNumber(value:chunkDownloadInfo.totalDownloaded)
                Swift.print("UUID:\(segmentDownloadData.segmentID):saving download data in DB \(segmentDownloadData.totalDownloaded)")
                
                do {
                    try context.save()
                    completion(nil)
                }catch {
                    Swift.print("saving falied :\(error.localizedDescription)")
                    completion(error)
                }
                
            }catch {
                completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil))
                Swift.print("loggin:error saving state")
            }
        }
    }
    
    final func updateDBWithFileDownloadInfo(fileDownloadInfo:FileDownloadDataInfo, completion:@escaping (_ error:Error?)-> ())
    {
        persistentContainer.performBackgroundTask { (context) in
            let existingFileDataFetchRequest: NSFetchRequest<NSFetchRequestResult> = FileDownloadData.fetchRequest()
            existingFileDataFetchRequest.predicate = NSPredicate(format: "fileDownloadID == %@", fileDownloadInfo.uniqueID)
            do {
                let fileDownloadDataArray =  try context.fetch(existingFileDataFetchRequest)
                guard let fileDownloadData = fileDownloadDataArray.last as? FileDownloadData
                    else {
                        
                        completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil))
                        return
                }
                fileDownloadData.fileDownloadID = fileDownloadInfo.uniqueID
                fileDownloadData.fileName = fileDownloadInfo.name
                fileDownloadData.fileDownloadURL = fileDownloadInfo.downloadURL
                fileDownloadData.totalSize = NSNumber(value:fileDownloadInfo.totalSize)
                fileDownloadData.fileType = fileDownloadInfo.type.rawValue
                fileDownloadData.totalDownloaded = NSNumber(value:fileDownloadInfo.totalDownloaded)
                fileDownloadData.isResumable = fileDownloadInfo.isResumeSupported
                fileDownloadData.diskDownloadBookMark = fileDownloadInfo.diskDownloadBookmarkData as NSData?
                fileDownloadData.diskDownloadURL = fileDownloadInfo.diskDownloadLocation
                fileDownloadData.runningStatus = fileDownloadInfo.runningStatus.rawValue
                fileDownloadData.downloadStartTime = fileDownloadInfo.startTimeStamp
                fileDownloadData.downloadEndTime = fileDownloadInfo.endTimeStamp
                fileDownloadData.isScheduled = fileDownloadInfo.isScheduled
                for segment in fileDownloadData.segments! {
                    let segmentData = segment as! SegmentDownloadData
                    if let indexOfChunkInfo = fileDownloadInfo.chuckDownloadData.index(where: { (chunk) -> Bool in
                        chunk.uniqueID == segmentData.segmentID
                    }){
                        let chunkDownloadInfo = fileDownloadInfo.chuckDownloadData[indexOfChunkInfo]
                        segmentData.startByte = NSNumber(value:chunkDownloadInfo.startByte)
                        segmentData.endByte = NSNumber(value:chunkDownloadInfo.endByte)
                        segmentData.segmentID = chunkDownloadInfo.uniqueID
                        segmentData.totalDownloaded = NSNumber(value:chunkDownloadInfo.totalDownloaded)
                    }
                   
                }
                do {
                    try context.save()
                    completion(nil)
                }catch {
                    Swift.print("saving falied :\(error.localizedDescription)")
                    completion(error)
                }
                            }
            catch {
                completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil))
                Swift.print("loggin:error saving state")
            }
        }
    }
    
    
    final func getAllTheFileDownloadInfoFromDB(completion:@escaping ((_ error:NSError?, _ fileDownloadInfoArray:[FileDownloadDataInfo]) -> ()))
    {
        var fileDownloadInfoArray = [FileDownloadDataInfo]()
        persistentContainer.performBackgroundTask { (context) in
            let existingFileDataFetchRequest: NSFetchRequest<NSFetchRequestResult> = FileDownloadData.fetchRequest()
            do {
                let fileDownloadDataArray =  try context.fetch(existingFileDataFetchRequest)
                guard  fileDownloadDataArray.count > 0
                    else {
                        
                        completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil), fileDownloadInfoArray)
                        return
                }
                for fileDownloadObject in fileDownloadDataArray {
                    guard let fileDownloadData =  fileDownloadObject as? FileDownloadData
                        else{
                            continue
                    }
              
                    //create segment array
                     var segmentArray = [ChunkDownloadData]()
                    //encrypt it
                    let userName = fileDownloadData.username?.decrypted
                    let password = fileDownloadData.password?.decrypted
                    if let segmensts = fileDownloadData.segments as? Set<SegmentDownloadData>{
                        for segment in segmensts{
                            let isSegmentCompleted = segment.totalDownloaded!.intValue >= (segment.endByte!.intValue - segment.startByte!.intValue)
                            let chunkData = ChunkDownloadData(uniqueID: segment.segmentID! , startByte: segment.startByte!.intValue, endByte: segment.endByte!.intValue, totalDownloaded: segment.totalDownloaded!.intValue, downloadURL: fileDownloadData.fileDownloadURL!, isCompleted: isSegmentCompleted, userName:userName, password:password)
                            segmentArray.append(chunkData)
                        }
                    }
                    
                    let fileDownloadInfo =  FileDownloadDataInfo(uniqueID: fileDownloadData.fileDownloadID! , name: fileDownloadData.fileName!, downloadURL: fileDownloadData.fileDownloadURL!, isResumeSupported: fileDownloadData.isResumable, type: fileTypes(rawValue: fileDownloadData.fileType!)!, startTimeStamp: fileDownloadData.downloadStartTime, endTimeStamp: fileDownloadData.downloadEndTime, diskDownloadLocation: fileDownloadData.diskDownloadURL!, diskDownloadBookmarkData: fileDownloadData.diskDownloadBookMark as Data?, runningStatus: downloadRunningStatus(rawValue:fileDownloadData.runningStatus!)! , totalSize: fileDownloadData.totalSize!.intValue, chuckDownloadData: segmentArray, totalDownloaded: fileDownloadData.totalDownloaded!.intValue, currentSpeed: 0, isNewDownload: false, userName:userName, password:password, isScheduled:fileDownloadData.isScheduled)
                    fileDownloadInfoArray.append(fileDownloadInfo)
                }
                runInMainThread {
                    completion(nil, fileDownloadInfoArray)
                }
            }
            catch {
                runInMainThread {
                     completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil), fileDownloadInfoArray)
                }
                Swift.print("loggin: coundn't get data from DB")
            }
        }
    }
    
    final func deleteDataForFileInfo(fileDownloadInfo:FileDownloadDataInfo, completion:@escaping (_ error:Error?)-> ())
    {
        persistentContainer.performBackgroundTask { (context) in
            let existingFileDataFetchRequest: NSFetchRequest<NSFetchRequestResult> = FileDownloadData.fetchRequest()
            existingFileDataFetchRequest.predicate = NSPredicate(format: "fileDownloadID == %@", fileDownloadInfo.uniqueID)
            do {
                let fileDownloadDataArray =  try context.fetch(existingFileDataFetchRequest)
                guard let fileDownloadData = fileDownloadDataArray.last as? FileDownloadData
                    else {
                        
                        completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil))
                        return
                }
                context.delete(fileDownloadData)
                do {
                    try context.save()
                    completion(nil)
                }catch {
                    Swift.print("saving falied :\(error.localizedDescription)")
                    completion(error)
                }
                
            }catch {
                completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil))
                Swift.print("loggin:error saving state")
            }
            
        }
    }
    
    final func deleteAllCompletedDownloadsEntry(completion:@escaping (_ error:Error?)-> ()) {
        persistentContainer.performBackgroundTask { (context) in
            let existingFileDataFetchRequest: NSFetchRequest<NSFetchRequestResult> = FileDownloadData.fetchRequest()
            existingFileDataFetchRequest.predicate = NSPredicate(format: "runningStatus == %@", "completed")
            do {
                let fileDownloadDataArray =  try context.fetch(existingFileDataFetchRequest)
                guard let fileDownloadDataList = fileDownloadDataArray as? [FileDownloadData]
                    else {
                        
                        completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil))
                        return
                }
                for fileDownloadData in fileDownloadDataList{
                    context.delete(fileDownloadData)
                }
              
                do {
                    try context.save()
                    completion(nil)
                }catch {
                    Swift.print("saving falied :\(error.localizedDescription)")
                    completion(error)
                }
                
            }catch {
                completion(NSError(domain: CoreDataErrors.domain, code: CoreDataErrors.nothingFound, userInfo: nil))
                Swift.print("loggin:error saving state")
            }
        }
    }
    
    
}
