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
        if speed < 1024 {
           return String(format:"%.1f bytes/seconds", speed)
        }
        
        if speed > 1024 && speed < (1024 * 1024) {
            return  String(format:"%.1f KB/seconds", speed / 1024)
        }
        
        if speed > (1024 * 1024) && speed < (1024 * 1024 * 1924) {
            return String(format:"%.1f MB/seconds", speed / (1024 * 1024))
        }
        
        return String(format:"%.1f GB/seconds", speed / (1024 * 1024 * 1024))
    }
    
    func representableStringForTime(seconds:Int) -> String{
        if seconds < 60 {
            return "\(seconds) Seconds"
        }
        
        if seconds < 60 * 60 {
            return "\(seconds / (60)) Minutes"
        }
        
        return "\(seconds / (60 * 60)) Hours"
    }
}
