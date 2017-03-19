//
//  IDMCoreDataHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

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
            fileDownloadData.totalSize = Int64(fileDownloadInfo.totalSize)
            fileDownloadData.fileType = fileDownloadInfo.type.rawValue
            fileDownloadData.totalDownloaded = Int64(fileDownloadInfo.totalDownloaded)
            fileDownloadData.isResumable = fileDownloadInfo.isResumeSupported
            fileDownloadData.diskDownloadBookMark = fileDownloadInfo.diskDownloadBookmarkData as NSData?
            fileDownloadData.diskDownloadURL = fileDownloadInfo.diskDownloadLocation
            fileDownloadData.runningStatus = fileDownloadInfo.runningStatus.rawValue
            fileDownloadData.downloadStartTime = fileDownloadInfo.startTimeStamp
            fileDownloadData.downloadEndTime = fileDownloadInfo.endTimeStamp
            var segmentsSet = Set<SegmentDownloadData>()
            for chunkDownloadInfo in fileDownloadInfo.chuckDownloadData {
                let segmentData = SegmentDownloadData(context: context)
                segmentData.startByte = Int64(chunkDownloadInfo.startByte)
                segmentData.endByte = Int64(chunkDownloadInfo.endByte)
                segmentData.segmentID = chunkDownloadInfo.uniqueID
                segmentData.totalDownloaded = Int64(chunkDownloadInfo.totalDownloaded)
                segmentData.resumeData = chunkDownloadInfo.resumeData as NSData?
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
    
    
}
