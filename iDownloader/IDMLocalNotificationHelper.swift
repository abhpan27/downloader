//
//  IDMLocalNotificationHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 27/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

final class IDMLocalNotificationHelper {
    
    static let shared = IDMLocalNotificationHelper()
    
    final func showNotification(title:String, infomativeText:String, userInfo:[String:String]) {
        let notification = NSUserNotification()
        notification.deliveryDate = Date()
        notification.title = title
        notification.informativeText = infomativeText
        notification.userInfo = userInfo
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }
}
