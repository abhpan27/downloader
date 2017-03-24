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

    
    @IBOutlet weak var secondButton: NSButton!
    @IBOutlet weak var firstButton: NSButton!
    @IBOutlet weak var container: NSView!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var timeRemainingLabel: NSTextField!
    @IBOutlet weak var downloadedLabel: NSTextField!
    @IBOutlet weak var percentDownloadedlabel: NSTextField!
    var uiUpdateTimer:Timer?
    
    
    
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
        var imageForFirstButton = NSImage(named: "RowPause")!
        if self.fileDownloadHelper!.fileDownloadData.runningStatus == .running {
            color = NSColor(IDMr: 65, g: 117, b: 5)
            progressView.foreground = NSColor(IDMr: 65, g: 117, b: 5)
        }else if fileDownloadHelper!.fileDownloadData.runningStatus == .paused {
            color = NSColor(IDMr: 74, g: 144, b: 226)
            imageForFirstButton = NSImage(named: "rowResume")!
            
        }else if fileDownloadHelper!.fileDownloadData.runningStatus == .failed {
            color = NSColor(IDMr: 208, g: 2, b: 27)
            imageForFirstButton = NSImage(named: "rowRetry")!
            
        }else {
            
        }
        progressView.foreground = color
        percentDownloadedlabel.textColor = color
        firstButton.image = imageForFirstButton
    }
    
    @IBAction func didSelectedFirstButton(_ sender: Any) {
        if self.fileDownloadHelper!.fileDownloadData.runningStatus == .running {
            pauseDownload()
        }else if self.fileDownloadHelper!.fileDownloadData.runningStatus == .failed {
            retryDownload()
        }else if self.fileDownloadHelper!.fileDownloadData.runningStatus == .paused {
            resumeDownload()
        }
    }
    
    @IBAction func didSelectedSecondButton(_ sender: Any) {
        
    }
    
    private func retryDownload() {
        
    }
    
    final func startUiUpdateTimer() {
        runInMainThread {
            [weak self]
            in
            guard let blockSelf = self
                else{
                    return
            }
            blockSelf.delegate?.insertNewDownloadRow(row: blockSelf.view)
            blockSelf.uiUpdateTimer?.invalidate()
            blockSelf.uiUpdateTimer =  Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (timer) in
                guard let blockSelf = self
                    else{
                        return
                }
                blockSelf.updateUIWithUIData()
            })
        }
    }
    
    private func resumeDownload() {
        self.startUiUpdateTimer()
        self.fileDownloadHelper?.resumeDownload(completion: { [weak self]
            (error)
            in
            guard let blockSelf = self
                else{
                    return
            }
            
            if error == nil {
                runInMainThread {
                     blockSelf.updateUIWithUIData()
                }
            }
        })
    }
    
    private func pauseDownload() {
        self.fileDownloadHelper?.pauseDownload(completion: { [weak self]
            (error)
            in
            guard let blockSelf = self
                else{
                    return
            }
            
            if error == nil {
                runInMainThread {
                    blockSelf.updateUIWithUIData()
                }
            }
        })
    }
    
    //MARK:FileDownloaderDelegate
    func newFileDataCreationFalied(){
        runInMainThread {
            IDMUtilities.shared.showError(title: "Oops!", information: "Something went wrong in starting download. Please try again")
        }
    }
    
    func newFileDownloadCreationSuccess(){
        startUiUpdateTimer()
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
    
    func newTempFileCreationFailed(){
        runInMainThread {
           IDMUtilities.shared.showError(title: "Oops!", information: "Not able to create download file at \(self.fileDownloadHelper!.fileDownloadData.diskDownloadLocation), Please try again")
        }
    }
    
    func downloadCompleted() {
        runInMainThread {
            Swift.print("completed download")
            self.updateUIWithUIData()
        }
    }
    
    func notAbleToWriteToDownloadFile(){
        runInMainThread {
            IDMUtilities.shared.showError(title: "Oops!", information: "Not able to write download file at \(self.fileDownloadHelper!.fileDownloadData.diskDownloadLocation), Please try again")
            self.updateUIWithUIData()
        }
    }
    
    func updateUIWithUIData(){
        self.setUpContentView()
        guard self.fileDownloadHelper!.fileDownloadData.runningStatus == .running
            else{
                self.uiUpdateTimer!.invalidate()
                return
        }
        let uiData = self.fileDownloadHelper!.currentUIData
        self.fileNameLabel.stringValue = self.fileDownloadHelper!.fileDownloadData.name
        self.downloadedLabel.stringValue = "Total downloaded - \(IDMUtilities.shared.representableStringForBytes(bytes: uiData.totalDownloaded)) of \(IDMUtilities.shared.representableStringForBytes(bytes: self.fileDownloadHelper!.fileDownloadData.totalSize))"
        let downloadedRatio = CGFloat(uiData.totalDownloaded)/CGFloat(self.fileDownloadHelper!.fileDownloadData.totalSize)
        self.progressView.progress = downloadedRatio
        self.percentDownloadedlabel.stringValue = String(format: "%.1f", downloadedRatio * 100) + "%"
        self.speedLabel.stringValue = "Download speed - \(IDMUtilities.shared.representableStringForSpeed(speed: uiData.speed))"
        self.timeRemainingLabel.stringValue = "Time remaining - \(IDMUtilities.shared.representableStringForTime(seconds:  uiData.timeRemaining))"
    }
    
    
    func pauseFailed() {
        runInMainThread {
            IDMUtilities.shared.showError(title: "Oops!", information: "Pause falied")
        }
    }
    
}

