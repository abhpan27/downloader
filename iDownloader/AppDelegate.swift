//
//  AppDelegate.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics


struct Constants {
    static let defaultSoundName = "Default"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    lazy var appController = IDMAppController()
    var window:NSWindow!

    override init() {
        super.init()
        let appleEventManager:NSAppleEventManager = NSAppleEventManager.shared()
        appleEventManager.setEventHandler(self, andSelector: #selector(AppDelegate.handleOpenWith(_:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Fabric.with([Crashlytics.self])
        IDMAnalyticsHelper.shared.checkAndLogFreshInstall()
        NSUserNotificationCenter.default.delegate = self
        if let userInfo = aNotification.userInfo{
            if let notification = userInfo[NSApplicationLaunchUserNotificationKey] as? NSUserNotification{
                if let userInfo = notification.userInfo  as? [String:String] {
                    if let downloadID = userInfo["downloadID"]{
                         self.appController.showDownloadCompletedPopUpForUniqueID(uniqueID: downloadID)
                    }
                   
                }
            }
        }
        
       
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.appController.checkAndAddURLFromPasteBoard()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        self.window.makeKeyAndOrderFront(self)
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        self.appController.doPauseAllOnAppQuit()
        return NSApplicationTerminateReply.terminateLater
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool{
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification){
        if let userInfo = notification.userInfo  as? [String:String] {
            if let downloadID = userInfo["downloadID"]{
                self.appController.showDownloadCompletedPopUpForUniqueID(uniqueID: downloadID)
            }
        }
    }
    
    func handleOpenWith(_ event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        let directObjectDescriptor = event?.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))
        let urlString = directObjectDescriptor?.stringValue;
        
        if let launchedURLString =  urlString{
            if let launchedURL = URL(string: launchedURLString) {
                    self.window?.makeKeyAndOrderFront(self)
                    self.appController.handleURLSchemeLaunch(downloadURL: launchedURL)
            }
        }
    }
    
}

