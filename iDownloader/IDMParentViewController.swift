//
//  IDMParentViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMParentViewController: NSViewController {

    @IBOutlet weak var filtersContainer: NSView!
    @IBOutlet weak var sideBarContainer: NSView!
    @IBOutlet weak var topBarContainer: NSView!
    @IBOutlet weak var listOfDownloadContainer: NSView!
    let headerController:IDMHeaderViewController
    let sideBarController:IDMSideBarController
    let downloadListController:IDMDownloadListController
    
    init() {
        headerController = IDMHeaderViewController()
        sideBarController = IDMSideBarController()
        downloadListController = IDMDownloadListController()
        super.init(nibName: "IDMParentViewController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.topBarContainer.addFittingSubView(subView: headerController.view)
        self.sideBarContainer.addFittingSubView(subView: sideBarController.view)
        self.listOfDownloadContainer.addFittingSubView(subView: downloadListController.view)
    }
    
}
