//
//  IDMDragLinkDetectorView.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 28/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol IDMDragLinkDetectorViewDelegate:class {
    func showOverlay()
    func removeOverlay()
    func didDroppedLink(path:String)
}

class IDMDragLinkDetectorView: NSView {
    
    weak var delegate:IDMDragLinkDetectorViewDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDropping()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDropping()
    }
    
    func registerForDropping() {
        register(forDraggedTypes: [NSURLPboardType])
    }
    
    override func mouseDown(with event: NSEvent) {
         setOverlayViewShown(false)
        super.mouseDown(with: event)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let urlList = sender.downloadURL()
        if urlList == nil {
            return NSDragOperation()
        }
        setOverlayViewShown(true)
        return NSDragOperation.copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let url = sender.downloadURL() {
            if let path = url.absoluteString{
                 delegate?.didDroppedLink(path: path)
            }
        }
        return true
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo?) {
        if overlayView != nil {
            setOverlayViewShown(false)
        }
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        if overlayView != nil {
            setOverlayViewShown(false)
        }
    }
    
    weak var overlayView: NSView!
    
    func setOverlayViewShown(_ show: Bool) {
        if show{
             delegate?.showOverlay()
        }else {
             delegate?.removeOverlay()
        }
       
    }
    
}
