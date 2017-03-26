//
//  IDMAppController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation
import Cocoa

final class IDMAppController:IDMPopUpDelgate {
    
    let parentController:IDMParentViewController
    var arrayOfPopUps = [IDMWindowController]()
    
    init() {
        parentController = IDMParentViewController()
    }
    
    func layOutUI() {
       let mainWindow = (NSApp.delegate as! AppDelegate).window
       // let screenRect = NSScreen.main()!.visibleFrame
        //mainWindow?.setFrame(screenRect, display: true)
        mainWindow?.contentViewController = parentController
    }
    
    func doPauseAllOnAppQuit() {
        self.parentController.downloadListController.pauseAllDownloads {
            NSApplication.shared().reply(toApplicationShouldTerminate: true)
        }
    }
    
    func showPopUpWithViewController(viewController:NSViewController, withSize:NSSize = NSSize(width: 400, height: 500)) {
        let popUpController = IDMWindowController(windowNibName: "IDMWindowController")
        popUpController.contentViewController = viewController
        let rect = popUpController.window!.getRectOfWindowInMiddle((NSApp.delegate as! AppDelegate).window, withSize:withSize )
        popUpController.window!.setFrame(rect, display: true)
        (NSApp.delegate as! AppDelegate).window.addChildWindow(popUpController.window!, ordered: NSWindowOrderingMode.above)
        popUpController.window!.makeKeyAndOrderFront(self)
        self.arrayOfPopUps.append(popUpController)
    }
    
    func didCloseWindow(sender:IDMWindowController) {
        if let index = self.arrayOfPopUps.index(where: { (popup) -> Bool in
            return popup == sender
        }){
            self.arrayOfPopUps.remove(at: index)
        }
    }
}
