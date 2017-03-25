//
//  AppDelegate.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var appController = IDMAppController()
    var window:NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        self.appController.doPauseAllOnAppQuit()
        return NSApplicationTerminateReply.terminateLater
    }
    

    
}

