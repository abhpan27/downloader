//
//  IDMUtilities.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 20/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

final class IDMUtilities {
    static let shared = IDMUtilities()
    
    func showError(title:String, information:String){
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = information
        alert.runModal()
    }
    
    func representableStringForBytes(bytes:Int) -> String{
        if bytes == Int.max {
            return "calculating..."
        }
        
        if bytes < 1024 {
            return "\(bytes) bytes"
        }
        
        if bytes > 1024 && bytes < (1024 * 1024) {
            return "\(bytes/1024) KB"
        }
        
        if bytes > (1024 * 1024) && bytes < (1024 * 1024 * 1924) {
            return "\(bytes/(1024 * 1024)) MB"
        }
        
        return "\(bytes / (1024 * 1024 * 1024)) GB"
    }
    
    func representableStringForSpeed(speed:Double) -> String {
        if speed == 0 {
            return "calculating..."
        }
        if speed < 1024 {
           return String(format:"%.1f bytes/S", speed)
        }
        
        if speed > 1024 && speed < (1024 * 1024) {
            return  String(format:"%.1f KB/S", speed / 1024)
        }
        
        if speed > (1024 * 1024) && speed < (1024 * 1024 * 1924) {
            return String(format:"%.1f MB/S", speed / (1024 * 1024))
        }
        
        return String(format:"%.1f GB/S", speed / (1024 * 1024 * 1024))
    }
    
    func representableStringForTime(seconds:Int) -> String{
        if seconds == Int.max {
            return "Calculating..."
        }
        if seconds < 60 {
            let suffix = seconds == 1 ? "Second" : "Seconds"
            return "\(seconds) " + suffix
        }
        
        if seconds < 60 * 60 {
            let remaingSeconds = seconds % (60)
            let minutes = seconds/60
            let minuteSuffix = minutes == 1 ? "Minute" : "Minutes"
            let scondSuffix = remaingSeconds == 1 ? "Second" : "Seconds"
            return "\(minutes) " + minuteSuffix + " \(remaingSeconds) " + scondSuffix
        }
        
        let remainingMinutes = seconds % (60 * 60)
        let hrs = seconds/(60 * 60)
        let minuteSuffix = remainingMinutes == 1 ? "Minute" : "Minutes"
        let hrsSuffix = hrs == 1 ? "Hour" : "Hours"
        return "\(hrs) "+hrsSuffix + " \(remainingMinutes) " + minuteSuffix
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        myPopup.addButton(withTitle: "Cancel")
        return myPopup.runModal() == NSAlertFirstButtonReturn
    }
    
    final func getMinutesFromMidnightForDate(_ date:Date) -> Int{
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.hour, .minute, .second]
        let components:DateComponents = (calendar as NSCalendar).components(unitFlags, from: date)
        let minutesFromMidNight = (components.hour)!*60 + (components.minute)!
        return minutesFromMidNight
    }
    
    final func getDateFromMinutesFromMidNight(_ minutesFromMidnight:Int) -> Date{
        let date = Date()
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.hour, .minute, .second, NSCalendar.Unit.day, NSCalendar.Unit.year, NSCalendar.Unit.month]
        var components:DateComponents = (calendar as NSCalendar).components(unitFlags, from: date)
        let hours = (minutesFromMidnight / 60)
        let minutes = (minutesFromMidnight % 60)
        components.hour = hours
        components.minute = minutes
        let dateToReturn = calendar.date(from: components)
        return dateToReturn!
    }
}
