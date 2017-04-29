//
//  IDMProDemoController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 29/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMProDemoController: NSViewController {

    @IBOutlet weak var percentDemp: NSTextField!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var segmentTitle: NSTextField!
    @IBOutlet weak var segmentDescription: NSTextField!
    @IBOutlet weak var supportDevelopememt: NSTextField!
    @IBOutlet weak var supportDevelopemtDescription: NSTextField!
    @IBOutlet weak var flagImage: NSImageView!
    @IBOutlet weak var buyProButton: IDMCustomGreenButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        progressView.foreground = NSColor(IDMr: 65, g: 117, b: 5)
        percentDemp.textColor = NSColor(IDMr: 65, g: 117, b: 5)
    }
    
    override func viewDidAppear() {
        resetViewState()
        runAnimation()
    }
    
    final func resetViewState() {
        progressView.progress = 0.0
        segmentTitle.alphaValue = 0.0
        supportDevelopememt.alphaValue = 0.0
        segmentDescription.alphaValue = 0.0
        supportDevelopemtDescription.alphaValue = 0.0
        flagImage.alphaValue = 0.0
        progressView.alphaValue = 0.0
        percentDemp.alphaValue = 0.0
        percentDemp.stringValue = "0 %"
    }
    
    final func runAnimation() {
        
        NSAnimationContext.runAnimationGroup({ [weak self](context) -> Void in
            if let blockSelf = self {
                context.duration = 0.7
                blockSelf.segmentTitle.animator().alphaValue = 1.0
                blockSelf.supportDevelopememt.animator().alphaValue = 1.0
                blockSelf.segmentDescription.animator().alphaValue = 1.0
                blockSelf.supportDevelopemtDescription.animator().alphaValue = 1.0
                blockSelf.flagImage.animator().alphaValue = 1.0
                blockSelf.progressView.animator().alphaValue = 1.0
                blockSelf.percentDemp.animator().alphaValue = 1.0
                
            }
            }, completionHandler:{
                self.progressView.progress = 1
                self.percentDemp.stringValue = "100 %"
        })
    }
}
