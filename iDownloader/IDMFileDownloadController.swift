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
    let speed:Int
    let timeRemaining:Int
}

class IDMFileDownloadController: NSViewController, FileDownloaderDelegate {

    
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var percentLabel: NSTextField!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var timeRemainingLabel: NSTextField!
    @IBOutlet weak var downloadedLabel: NSTextField!
    
    
    
    
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
    }
    
    final func createFileDataHelperAndBeginDownload(fileDownloadInfo:FileDownloadDataInfo){
        self.fileDownloadHelper = IDMFileDownloadDataHelper(delegate: self, fileDownloadInfo: fileDownloadInfo)
        self.fileDownloadHelper?.startDownloading()
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
            Timer.scheduledTimer(timeInterval: 0.3, target: blockSelf, selector: #selector(IDMFileDownloadController.updateUIWithUIData), userInfo: nil, repeats: true)
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
        let uiData = self.fileDownloadHelper!.currentUIData
        self.fileNameLabel.stringValue = self.fileDownloadHelper!.fileDownloadData.name
        self.downloadedLabel.stringValue = "\(uiData.totalDownloaded)bytes of \(self.fileDownloadHelper!.fileDownloadData.totalSize)bytes"
        self.percentLabel.stringValue = "\((uiData.totalDownloaded * 100)/self.fileDownloadHelper!.fileDownloadData.totalSize)%"
        self.speedLabel.stringValue = "\(uiData.speed) bytes/Seconds"
        self.timeRemainingLabel.stringValue = "\(uiData.timeRemaining) Seconds"
        
    }
    
}

