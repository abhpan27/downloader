//
//  IDMAppController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation
import Cocoa

final class IDMAppController {
    
    let parentController:IDMParentViewController
    
    init() {
        parentController = IDMParentViewController()
    }
    
    func layOutUI() {
       let mainWindow = (NSApp.delegate as! AppDelegate).window
       // let screenRect = NSScreen.main()!.visibleFrame
        //mainWindow?.setFrame(screenRect, display: true)
        mainWindow?.contentViewController = parentController
    }
}
