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
    
    var hasAlreadyRated:Bool {
        let hasAlreadyRatedApp = UserDefaults.standard.value(forKey: SettingsKeys.hasAlreadyRatedApp) as? Bool ?? false
        return hasAlreadyRatedApp
    }
    
    var hasSeletectedNotAskRatings:Bool {
        let hasSeletectedNotAskRatings = UserDefaults.standard.value(forKey: SettingsKeys.hasSeletectedNotAskRatings) as? Bool ?? false
        return hasSeletectedNotAskRatings
    }
    
    var isFreshInstall:Bool {
        if let _ = UserDefaults.standard.value(forKey: SettingsKeys.isFreshInstall){
            return false
        }
        return true
    }
    
    var shouldRunSchedulerDaily:Bool {
        if let shouldRunSchedulerDaily = UserDefaults.standard.value(forKey: SettingsKeys.shouldRunSchedulerDaily) as? Bool{
            return shouldRunSchedulerDaily
        }
        return true
    }
    
    var defaultSheduledWeekDays:[Int]{
        if let weekDays = UserDefaults.standard.value(forKey: SettingsKeys.scheduledWeekDays) as? [Int]{
            return weekDays
        }
        return [1,2,3,4,5,6,7]
    }
    
    var defaultBookMarkData: Data? {
        if let defaultBookMarkData = UserDefaults.standard.value(forKey:  SettingsKeys.defaultBookMarkData) as? Data{
            return defaultBookMarkData
        }
        return nil
    }
    
    var pruchasedID:String {
        if let IDData = UserDefaults.standard.value(forKey:  SettingsKeys.userDeviceIDHash) as? Data {
            if let stringID = String(data: IDData, encoding: String.Encoding.utf8){
                return stringID.decrypted!
            }
        }
        return "some random shit"
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
        let segmentCounts = UserDefaults.standard.value(forKey: SettingsKeys.noOfSegmennts) as? Int ?? Constants.defaultNumberOfSegments
        if !IAPHelper.shared.isProductPurchased(Constants.productInAppID) && segmentCounts > Constants.defaultNumberOfSegments{
            return Constants.defaultNumberOfSegments
        }
        return segmentCounts
    }
    
    var defaultSchedulerStartDate:Date {
        var defaultValueForWeekDayStartAt = (10 * 60) // 10AM
        if let startMintuesFromMidNight = UserDefaults.standard.value(forKey: SettingsKeys.schedulerStartTime) as? Int {
            defaultValueForWeekDayStartAt = startMintuesFromMidNight
        }
         return IDMUtilities.shared.getDateFromMinutesFromMidNight(defaultValueForWeekDayStartAt)
    }
    
    var defaultSchedulerStopDate:Date {
        var defaultValueForWeekDayStartAt = (22 * 60) // 10PM
        if let startMintuesFromMidNight = UserDefaults.standard.value(forKey: SettingsKeys.schedulerStopTime) as? Int {
            defaultValueForWeekDayStartAt = startMintuesFromMidNight
        }
        return IDMUtilities.shared.getDateFromMinutesFromMidNight(defaultValueForWeekDayStartAt)
    }
    
    
    final func setDefaultValueForShouldShowNotification(value:Bool){
        UserDefaults.standard.set(value, forKey: SettingsKeys.shouldShowNotificationOnDownload)
        UserDefaults.standard.synchronize()
    }
    
    final func setDefaultValueForShouldRunSchedulerDaily(value:Bool){
        UserDefaults.standard.set(value, forKey: SettingsKeys.shouldRunSchedulerDaily)
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
    
    final func setIsFreshInstall(){
        UserDefaults.standard.set(1, forKey:   SettingsKeys.isFreshInstall)
        UserDefaults.standard.synchronize()
    }
    
    final func setNotAsk() {
        UserDefaults.standard.set(1, forKey:   SettingsKeys.hasSeletectedNotAskRatings)
        UserDefaults.standard.synchronize()
    }
    
    final func setAlreadyRated() {
        UserDefaults.standard.set(1, forKey:   SettingsKeys.hasAlreadyRatedApp)
        UserDefaults.standard.synchronize()
    }
    
    final func setSchedulerWeekDays(weekDays:[Int]){
        UserDefaults.standard.set(weekDays, forKey:   SettingsKeys.scheduledWeekDays)
        UserDefaults.standard.synchronize()
    }
    
    final func setStartSchedulerTime(time:Date){
        let hrs = IDMUtilities.shared.getMinutesFromMidnightForDate(time)
        UserDefaults.standard.set(hrs, forKey: SettingsKeys.schedulerStartTime)
    }
    
    final func setStopSchedulerTime(time:Date) {
        let hrs = IDMUtilities.shared.getMinutesFromMidnightForDate(time)
        UserDefaults.standard.set(hrs, forKey: SettingsKeys.schedulerStopTime)
    }
    
    final func setPurchasedProduct(identifier:String) {
        let hash = identifier.encrypted!
        let data = hash.data(using: String.Encoding.utf8)
        UserDefaults.standard.set(data, forKey:   SettingsKeys.userDeviceIDHash)
        UserDefaults.standard.synchronize()
    }
    
}
