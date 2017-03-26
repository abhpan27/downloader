//
//  NSWindowExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 26/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension NSWindow {
    
    final func getRectOfWindowInMiddle(_ parentWindow:NSWindow , withSize:NSSize) -> NSRect{
        let size: NSSize
        if (withSize.width == 0 && withSize.height == 0) {
            size = self.frame.size
        } else {
            size = withSize
        }
        
        let frameOfParentWindowInScreenCoord = parentWindow.frame
        let rectForWindow = NSMakeRect(frameOfParentWindowInScreenCoord.midX - (size.width/2), frameOfParentWindowInScreenCoord.midY - (size.height/2), size.width, size.height)
        return rectForWindow
    }
}
