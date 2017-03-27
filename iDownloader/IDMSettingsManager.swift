//
//  IDMSettingsManager.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 27/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa


final class IDMSettingsManager {
    
    static let shared = IDMSettingsManager()
    
    var shouldShowNotification: Bool {
        let shouldShowNotification = UserDefaults.standard.value(forKey: SettingsKeys.shouldShowNotificationOnDownload) as? Bool ?? true
        return shouldShowNotification
        
    }
    
    var defaultBookMarkData: Data? {
        if let defaultBookMarkData = UserDefaults.standard.value(forKey:  SettingsKeys.defaultBookMarkData) as? Data{
            return defaultBookMarkData
        }
        return nil
    }
    
    var defaultNotificationSound:String {
        let notificationSound = UserDefaults.standard.value(forKey: SettingsKeys.notificationSound) as? String ?? Constants.defaultSoundName
        return notificationSound
    }
    
    var defaultDownloadPath:String {
        if let defaultBookMarkData = UserDefaults.standard.value(forKey:  SettingsKeys.defaultBookMarkData) as? Data {
            if let bookMarkURL = IDMFileHandler().getURLFromBookMarkData(bookmarkData: defaultBookMarkData){
                let pathWithoutSystemLink = bookMarkURL.urlAfterResolvingSytemLink.path
                return pathWithoutSystemLink
            }
        }
        
        return IDMFileManager.shared.defaultDownloadURL.path
    }
    
    var defaultNumberOfSegments:Int {
        let segmentCounts = UserDefaults.standard.value(forKey: SettingsKeys.noOfSegmennts) as? Int ?? 6
        return segmentCounts
    }
    
    
    final func setDefaultValueForShouldShowNotification(value:Bool){
        UserDefaults.standard.set(value, forKey: SettingsKeys.shouldShowNotificationOnDownload)
        UserDefaults.standard.synchronize()
    }
    
    final func setValueForDefaultBookMark(bookMark:Data){
        UserDefaults.standard.set(bookMark, forKey: SettingsKeys.defaultBookMarkData)
        UserDefaults.standard.synchronize()
    }
    
    
    final func setDefaultNotificationSound(sound:String){
        UserDefaults.standard.set(sound, forKey:  SettingsKeys.notificationSound)
        UserDefaults.standard.synchronize()
    }
    
    final func setDefaultNumberOfSegments(segments:Int){
        UserDefaults.standard.set(segments, forKey:   SettingsKeys.noOfSegmennts)
        UserDefaults.standard.synchronize()
    }
    
}
