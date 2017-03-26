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
    func removeDownloader(downloadController:IDMFileDownloadController)
    func startLoader()
    func stopLoader()
    func scrollToBottom()
}

struct UIData{
    let totalDownloaded:Int
    var speedArray:[Double]
    let timeRemaining:Int
    var isRetyringOnError:Bool
}

class IDMFileDownloadController: NSViewController, FileDownloaderDelegate, IDMFiledownloaderViewDelegate, FileOpenPopUpDelegate {

    
    @IBOutlet weak var fileCompletionImage: NSImageView!
    @IBOutlet weak var fileCompletionImageContainer: NSView!
    @IBOutlet weak var verticalLine: NSBox!
    @IBOutlet weak var horizontalLine: NSBox!
    @IBOutlet weak var secondButton: NSButton!
    @IBOutlet weak var firstButton: NSButton!
    @IBOutlet weak var container: IDMFiledownloaderView!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var timeRemainingLabel: NSTextField!
    @IBOutlet weak var downloadedLabel: NSTextField!
    @IBOutlet weak var percentDownloadedlabel: NSTextField!
    var uiUpdateTimer:Timer?
    let KB = 1024
    
    
    
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
        
        self.fileCompletionImageContainer.wantsLayer = true
        self.fileCompletionImageContainer.layer?.backgroundColor = NSColor.clear.cgColor
        self.fileCompletionImageContainer.layer?.borderWidth = 1.0
        self.fileCompletionImageContainer.layer?.borderColor = NSColor(IDMr: 155, g: 155, b: 155).cgColor
        container.delegate = self
    }
    
    final func createFileDataHelperAndBeginDownload(fileDownloadInfo:FileDownloadDataInfo, shouldForceStartPauseDownload:Bool){
        self.fileDownloadHelper = IDMFileDownloadDataHelper(delegate: self, fileDownloadInfo: fileDownloadInfo)
        if fileDownloadInfo.runningStatus == .running || fileDownloadInfo.runningStatus == .paused{
            self.fileDownloadHelper?.startDownloading(shouldForceStartPauseDownload: shouldForceStartPauseDownload)
        }
        self.addControllerInList()
        delay(0.1, closure: {
            self.updateUIWithUIData()
            self.delegate?.stopLoader()
        })
        
    }
    
    private func setUpContentView() {
        self.container.alphaValue = 1.0
        var color = NSColor.clear
        self.firstButton.isEnabled = true
        self.timeRemainingLabel.isHidden = false
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
            
        }else if fileDownloadHelper!.fileDownloadData.runningStatus == .completed {
            showCompletedUI()
            return
        }
        progressView.foreground = color
        percentDownloadedlabel.textColor = color
        firstButton.image = imageForFirstButton
        if fileDownloadHelper!.currentUIData.isRetyringOnError{
            progressView.foreground = NSColor(IDMr: 245, g: 166, b: 35)
            percentDownloadedlabel.textColor = NSColor(IDMr: 245, g: 166, b: 35)
            showRetryingText()
            self.firstButton.isEnabled = false
        }
        
        if !fileDownloadHelper!.fileDownloadData.isResumeSupported && fileDownloadHelper!.fileDownloadData.runningStatus != .failed {
            self.firstButton.isEnabled = false
        }
        
        if fileDownloadHelper!.fileDownloadData.runningStatus == .failed{
            self.firstButton.isEnabled = true
            self.timeRemainingLabel.isHidden = true
            self.speedLabel.stringValue = "Download failed"
        }
        
        if fileDownloadHelper!.fileDownloadData.runningStatus == .paused {
            self.timeRemainingLabel.isHidden = true
            self.speedLabel.stringValue = "Paused currently"
        }
        
    }
    
    private func showRetryingText() {
        speedLabel.stringValue = "Speed - Retrying...."
        timeRemainingLabel.stringValue = "Time Remaining - Calculating..."
    }
    
    private func showCompletedUI() {
        verticalLine.isHidden = true
        horizontalLine.isHidden = true
        secondButton.isHidden = true
        firstButton.isHidden = true
        progressView.isHidden = true
        timeRemainingLabel.isHidden = true
        percentDownloadedlabel.isHidden = true
        speedLabel.stringValue =  "Download completed on - " + Date(timeIntervalSince1970: self.fileDownloadHelper!.fileDownloadData.endTimeStamp).representableDate
        downloadedLabel.stringValue = self.fileDownloadHelper!.fileDownloadData.type.nameForType
        fileCompletionImageContainer.isHidden = false
        fileCompletionImage.image = self.fileDownloadHelper!.fileDownloadData.type.imageForFileType
        fileCompletionImageContainer.layer?.cornerRadius =  fileCompletionImageContainer.frame.height/2
        fileNameLabel.stringValue = self.fileDownloadHelper!.fileDownloadData.name
    }
    
    @IBAction func didSelectedFirstButton(_ sender: Any) {
        if self.fileDownloadHelper!.fileDownloadData.runningStatus == .running {
            pauseDownload(completion: nil)
        }else if self.fileDownloadHelper!.fileDownloadData.runningStatus == .failed {
            retryDownload()
        }else if self.fileDownloadHelper!.fileDownloadData.runningStatus == .paused {
            resumeDownload(completion: nil)
        }
    }
    
    @IBAction func didSelectedSecondButton(_ sender: Any) {
        self.deleteDownload()
    }
    
    final func startUiUpdateTimer() {
        runInMainThread {
            [weak self]
            in
            guard let blockSelf = self
                else{
                    return
            }
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
    
    fileprivate func addControllerInList()  {
        runInMainThread {
            self.delegate?.insertNewDownloadRow(row: self.view)
            self.delegate?.scrollToBottom()
        }
    }
    
    final func resumeDownload(completion:(() -> ())?) {
        if self.fileDownloadHelper!.fileDownloadData.runningStatus != .paused {
            completion?()
            return
        }
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
            completion?()
        })
    }
    
    final func pauseDownload(completion:(() -> ())?) {
        if self.fileDownloadHelper!.fileDownloadData.runningStatus != .running {
            completion?()
            return
        }
        self.fileDownloadHelper?.pauseDownload(completion: { [weak self]
            (error)
            in
            guard let blockSelf = self
                else{
                    return
            }
            
            if error == nil {
                runInMainThread {
                    blockSelf.uiUpdateTimer?.invalidate()
                    blockSelf.updateUIWithUIData()
                }
            }
            completion?()
        })
    }
    
    //MARK:FileDownloaderDelegate
    func newFileDataCreationFalied(){
        runInMainThread {
            IDMUtilities.shared.showError(title: "Oops!", information: "Something went wrong in starting download. Please try again")
            self.uiUpdateTimer?.invalidate()
        }
    }
    
    func downloadStarted() {
        self.addControllerInList()
        self.startUiUpdateTimer()
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
            self.uiUpdateTimer?.invalidate()
        }
    }
    
    func downloadCompleted() {
        runInMainThread {
            Swift.print("completed download")
            self.updateUIWithUIData()
            self.uiUpdateTimer?.invalidate()
        }
    }
    
    func notAbleToWriteToDownloadFile(){
        runInMainThread {
            IDMUtilities.shared.showError(title: "Oops!", information: "Not able to write download file at \(self.fileDownloadHelper!.fileDownloadData.diskDownloadLocation), Please try again")
            self.updateUIWithUIData()
            self.uiUpdateTimer?.invalidate()
        }
    }
    
    func updateUIWithUIData(){
        let uiData = self.fileDownloadHelper!.currentUIData
        self.fileNameLabel.stringValue = self.fileDownloadHelper!.fileDownloadData.name
        self.downloadedLabel.stringValue = "Total downloaded - \(IDMUtilities.shared.representableStringForBytes(bytes: uiData.totalDownloaded)) of \(IDMUtilities.shared.representableStringForBytes(bytes: self.fileDownloadHelper!.fileDownloadData.totalSize))"
        let downloadedRatio = CGFloat(uiData.totalDownloaded)/CGFloat(self.fileDownloadHelper!.fileDownloadData.totalSize)
        self.progressView.progress = downloadedRatio
        self.percentDownloadedlabel.stringValue = String(format: "%.1f", downloadedRatio * 100) + "%"
        self.speedLabel.stringValue = "Download speed - \(IDMUtilities.shared.representableStringForSpeed(speed: uiData.speedArray.average))"
        self.timeRemainingLabel.stringValue = "Time remaining - \(IDMUtilities.shared.representableStringForTime(seconds:  uiData.timeRemaining))"
        self.setUpContentView()
    }
    
    
    func pauseFailed() {
        runInMainThread {
            IDMUtilities.shared.showError(title: "Oops!", information: "Pause falied")
        }
    }
    
    func downloadFalied(isNonResumable:Bool){
        runInMainThread {
            if isNonResumable{
                IDMUtilities.shared.showError(title: "Download Failed :(", information: "Downloading file \(self.fileDownloadHelper!.fileDownloadData.name) falied. Server don't support resume for this file download. Please try downloading it on good internet connection")
            }else {
                IDMUtilities.shared.showError(title: "Download Failed :(", information: "Downloading file \(self.fileDownloadHelper!.fileDownloadData.name) falied. Something went wrong while downloading. Please try again")
            }
        }
    }
    
    final func deleteDownload() {
        self.fileDownloadHelper!.cancelDownloading { (error) in
            IDMCoreDataHelper.shared.deleteDataForFileInfo(fileDownloadInfo: self.fileDownloadHelper!.fileDownloadData) {[weak self]
                (error)
                in
                guard let blockSelf = self
                    else {
                        return
                }
                runInMainThread {
                    _ = blockSelf.fileDownloadHelper!.removeTempFileForDownload()
                    blockSelf.delegate?.removeDownloader(downloadController: blockSelf)
                }
            }
        }
    }
    
    private func retryDownload() {
        _ = self.fileDownloadHelper!.removeTempFileForDownload()
        self.fileDownloadHelper?.clearAllDataAndReStart()
    }
    
    //MARK:IDMFiledownloaderViewDelegate
    func didMouseDown() {
        if self.fileDownloadHelper?.fileDownloadData.runningStatus == .completed {
            self.showOpenFilePanel()
        }
    }
    
    func isCompleted() -> Bool {
        return self.fileDownloadHelper!.fileDownloadData.runningStatus == .completed
    }
    
    func showOpenFilePanel() {
        let openPanelViewController = IDMDownloadCompleteViewController(delegate: self, fileDonwloadInfo: self.fileDownloadHelper!.fileDownloadData)
        (NSApp.delegate as! AppDelegate).appController.showPopUpWithViewController(viewController: openPanelViewController, withSize: NSSize(width: 400, height: 320))
    }
    
    //MARK:FileOpenPopUpDelegate
    func didNotFindFile() {
        self.deleteDownload()
    }
    
}

