//
//  IDMScrollViewExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 26/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension NSScrollView {
    
    //MARK: scrollToTop
    func scrollToBottom() {
        let newOrigin: NSPoint = NSMakePoint(0, NSMaxY(documentView!.frame) - bounds.size.height)
        
        NSAnimationContext.beginGrouping()
        
        if hasVerticalScroller {
            verticalScroller!.animator().floatValue = 0
        }
        
        NSAnimationContext.current().duration = 0.3
        let clipView = contentView
        clipView.animator().setBoundsOrigin(newOrigin)
        reflectScrolledClipView(contentView)
        NSAnimationContext.endGrouping()
    }
    
    //MARK: scrollToBottom
    func scrollToTop() {
        
        let newOrigin: NSPoint = NSMakePoint(0, -(contentView.documentView!.frame.size.height))
        
        NSAnimationContext.beginGrouping()
        
        if hasVerticalScroller {
            verticalScroller!.animator().floatValue = 1
        }
        
        NSAnimationContext.current().duration = 0.4
        let clipView = contentView
        clipView.animator().setBoundsOrigin(newOrigin)
        reflectScrolledClipView(contentView)
        NSAnimationContext.endGrouping()
    }
   
}
