//
//  IDMFileDownloadController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol FileDownloadControllerDelegate:class {
    func insertNewDownloadRow(row:NSView)
    func startLoader()
    func stopLoader()
}

struct UIData{
    let totalDownloaded:Int
    let speed:Double
    let timeRemaining:Int
}

class IDMFileDownloadController: NSViewController, FileDownloaderDelegate {

    
    @IBOutlet weak var container: NSView!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var timeRemainingLabel: NSTextField!
    @IBOutlet weak var downloadedLabel: NSTextField!
    @IBOutlet weak var percentDownloadedlabel: NSTextField!
    
    
    
    
    var fileDownloadHelper:IDMFileDownloadDataHelper?
    weak var delegate:FileDownloadControllerDelegate?
    
    init(delegate:FileDownloadControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: "IDMFileDownloadController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        container.wantsLayer = true
        container.layer?.borderWidth = 1.0
        container.layer?.borderColor = NSColor(IDMr: 178, g: 164, b: 164).cgColor
        container.layer?.backgroundColor = NSColor.white.cgColor
        self.container.alphaValue = 0
    }
    
    final func createFileDataHelperAndBeginDownload(fileDownloadInfo:FileDownloadDataInfo){
        self.fileDownloadHelper = IDMFileDownloadDataHelper(delegate: self, fileDownloadInfo: fileDownloadInfo)
        self.fileDownloadHelper?.startDownloading()
    }
    
    private func setUpContentView() {
        self.container.alphaValue = 1.0
        var color = NSColor.clear
        if self.fileDownloadHelper!.fileDownloadData.runningStatus == .running {
            color = NSColor(IDMr: 65, g: 117, b: 5)
            progressView.foreground = NSColor(IDMr: 65, g: 117, b: 5)
        }else if fileDownloadHelper!.fileDownloadData.runningStatus == .paused {
            color = NSColor(IDMr: 74, g: 144, b: 226)
            
        }else if fileDownloadHelper!.fileDownloadData.runningStatus == .failed {
            color = NSColor(IDMr: 208, g: 2, b: 27)
            
        }else {
            
        }
        
        progressView.foreground = color
        percentDownloadedlabel.textColor = color
    }
    
    //MARK:FileDownloaderDelegate
    func newFileDataCreationFalied(){
        IDMUtilities.shared.showError(title: "Oops!", information: "Something went wrong in starting download. Please try again")
    }
    
    func newFileDownloadCreationSuccess(){
        
        runInMainThread {
            [weak self]
            in
            guard let blockSelf = self
                else{
                    return
            }
            //blockSelf.updateUIWithUIData()
            blockSelf.delegate?.insertNewDownloadRow(row: blockSelf.view)
            Timer.scheduledTimer(timeInterval: 0.2, target: blockSelf, selector: #selector(IDMFileDownloadController.updateUIWithUIData), userInfo: nil, repeats: true)
        }
       
    }
    
    func showLoader() {
        runInMainThread {
            self.delegate?.startLoader()
        }
    }
    
    func hideLoader() {
        runInMainThread {
            self.delegate?.stopLoader()
        }
    }
    
    func updateUIWithUIData(){
        setUpContentView()
        let uiData = self.fileDownloadHelper!.currentUIData
        self.fileNameLabel.stringValue = self.fileDownloadHelper!.fileDownloadData.name
        self.downloadedLabel.stringValue = "Total downloaded - \(IDMUtilities.shared.representableStringForBytes(bytes: uiData.totalDownloaded)) of \(IDMUtilities.shared.representableStringForBytes(bytes: self.fileDownloadHelper!.fileDownloadData.totalSize))"
        let downloadedRatio = CGFloat(uiData.totalDownloaded)/CGFloat(self.fileDownloadHelper!.fileDownloadData.totalSize)
        self.progressView.progress = downloadedRatio
        percentDownloadedlabel.stringValue = String(format: "%.1f", downloadedRatio * 100) + "%"
        self.speedLabel.stringValue = "Download speed - \(IDMUtilities.shared.representableStringForSpeed(speed: uiData.speed))"
        self.timeRemainingLabel.stringValue = "Time remaining - \(IDMUtilities.shared.representableStringForTime(seconds:  uiData.timeRemaining))"
        
    }
    
}

