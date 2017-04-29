//
//  IDMProRow.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 29/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol IDMShowProProtocol:class {
    func didSelectedShowPro()
}

class IDMProRow: NSView {

    static let IDMViewName = "IDMProRow"
    
    static func createView() -> IDMProRow {
        
        
        var array = NSArray()
        let nibContent = AutoreleasingUnsafeMutablePointer<NSArray>?(&array)
        
        Bundle.main.loadNibNamed(IDMViewName, owner: nil, topLevelObjects: nibContent)
        let view = nibContent!.pointee.filter { $0 is IDMProRow }.first as! IDMProRow
        return view
    }
    
    @IBOutlet weak var rocketContainer: NSView!
    @IBOutlet weak var container: NSView!
    
    override func viewDidMoveToWindow() {
        container.wantsLayer = true
        container.layer?.borderWidth = 1.0
        container.layer?.borderColor = NSColor(IDMr: 178, g: 164, b: 164).cgColor
        container.layer?.backgroundColor = NSColor.white.cgColor
        rocketContainer.wantsLayer = true
        rocketContainer.layer?.borderWidth = 1.0
        rocketContainer.layer?.borderColor = NSColor(IDMr: 79, g: 79, b: 79).cgColor
        rocketContainer.layer?.cornerRadius =  rocketContainer.frame.width/2
    }
    
    
    weak var delegate:IDMShowProProtocol?
    fileprivate var trackingArea:NSTrackingArea?
    
    override func updateTrackingAreas()
    {
        if (self.trackingArea != nil) {
            self.removeTrackingArea(trackingArea!)
        }
        
        self.trackingArea = NSTrackingArea(
            rect: self.visibleRect,
            options: [NSTrackingAreaOptions.activeInActiveApp, NSTrackingAreaOptions.cursorUpdate],
            owner: self,
            userInfo: nil
        )
        
        if (self.trackingArea != nil) {
            self.addTrackingArea(self.trackingArea!)
        }
        
        super.updateTrackingAreas()
    }
    
    override func mouseDown(with event: NSEvent) {
        delegate?.didSelectedShowPro()
    }
    
    override func cursorUpdate(with event: NSEvent) {
        NSCursor.pointingHand().set()
        
    }
    
    override func resetCursorRects() {
        self.addCursorRect(self.visibleRect, cursor: NSCursor.pointingHand())
    }
}
