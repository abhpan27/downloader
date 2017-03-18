//
//  IDMParentViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMParentViewController: NSViewController, HeaderActionDelegate {

    @IBOutlet weak var filtersContainer: NSView!
    @IBOutlet weak var sideBarContainer: NSView!
    @IBOutlet weak var topBarContainer: NSView!
    @IBOutlet weak var listOfDownloadContainer: NSView!
    @IBOutlet weak var fileTypeLabel: NSTextField!
    @IBOutlet weak var downloadFolderTextField: NSTextField!
    @IBOutlet weak var fileNameTextField: NSTextField!
    @IBOutlet weak var threadsTextField: NSTextField!
    @IBOutlet weak var addDownloadPopUpView: IDMMouseEventBlockingView!
    @IBOutlet var addDownloadContainer: IDMMouseEventBlockingView!
    
    
    
    var headerController:IDMHeaderViewController!
    var sideBarController:IDMSideBarController!
    var downloadListController:IDMDownloadListController!
    
    init() {
        super.init(nibName: "IDMParentViewController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        headerController = IDMHeaderViewController(headerDelegate:self)
        sideBarController = IDMSideBarController()
        downloadListController = IDMDownloadListController()
        self.topBarContainer.addFittingSubView(subView: headerController.view)
        self.sideBarContainer.addFittingSubView(subView: sideBarController.view)
        self.listOfDownloadContainer.addFittingSubView(subView: downloadListController.view)
    }
    
    //MARK:Download starting point
    private func startDownload(downloadUrl: String) {
        guard let urlFromString = URL(string: downloadUrl)
            else {
                return
        }
        
        let fileNameAndExtesion = urlFromString.lastPathComponent.components(separatedBy: ".")
        guard  fileNameAndExtesion.count == 2
            else{
                return
        }
        
        let fileName = fileNameAndExtesion[0]
        let fileExtension = fileNameAndExtesion[1]
        let fileType = IDMFileTypeHelper().getFileType(fileExtension: fileExtension)
       //show popup
        setUpUIandAddDownloadPopUp()
    }
   
    
    //MARK:HeaderActionDelegate
    func didSelectedStartDownload(downloadUrl: String) {
        startDownload(downloadUrl:downloadUrl)
    }
    
}

//MARK: Add download UI
extension IDMParentViewController: MouseDownDelgate {
    final func setUpUIandAddDownloadPopUp() {
        self.view.addFittingSubView(subView: addDownloadContainer)
        addDownloadContainer.delegate = self
    }
    
    func didMouseDown() {
        addDownloadContainer.delegate = nil
        addDownloadContainer.removeFromSuperview()
    }
}
