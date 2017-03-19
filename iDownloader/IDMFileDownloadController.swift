//
//  IDMFileDownloadController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 19/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol FileDownloadControllerDelegate:class {
    
}

class IDMFileDownloadController: NSViewController, FileDownloaderDelegate {

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
        
    }
    
    func newFileDownloadCreationSuccess(){
        
    }
    
}

