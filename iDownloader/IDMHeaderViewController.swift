//
//  IDMHeaderViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 18/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

protocol HeaderActionDelegate:class{
    func didSelectedStartDownloadFromHeader(downloadUrl:String)
}

class IDMHeaderViewController: NSViewController, IDMProViewClickProtocol{

    @IBOutlet weak var widthOfProView: NSLayoutConstraint!
    @IBOutlet weak var procustomView: IDMProCustomView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var downloadLinkTextField: NSTextField!
    @IBOutlet weak var addDownloadContainer: NSView!
    @IBOutlet weak var addButton: NSButton!
    weak var headerActionDelgate:HeaderActionDelegate?
    var proWindowController:IDMProWindowController?
    
    init(headerDelegate:HeaderActionDelegate){
        self.headerActionDelgate = headerDelegate
        super.init(nibName: "IDMHeaderViewController", bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        addDownloadContainer.wantsLayer = true
        addDownloadContainer?.layer?.borderWidth = 1.0
        addDownloadContainer.layer?.cornerRadius =  5
        addDownloadContainer?.layer?.borderColor = NSColor(IDMr: 178, g: 164, b: 164).cgColor
        procustomView.delegate = self
        checkAndHideProButton()
        NotificationCenter.default.addObserver(self, selector: #selector(IDMHeaderViewController.handlePurchasedNotification),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
    }
    
    @IBAction func didSelectedAddDowload(_ sender: Any) {
        checkAndStartDownload()
    }
    
    final func setTitle(tileString:String){
        self.titleLabel.stringValue = tileString
    }
    
    final func handlePurchasedNotification() {
        runInMainThread {
            self.hideProView()
            self.proWindowController?.close()
            self.proWindowController = nil
            self.showErorr(title: "Thank you!", message: "You have now access to iDownloader pro. Experience the speed :)")
        }
    }
    
    private func checkAndHideProButton() {
        if IAPHelper.shared.isProductPurchased(Constants.productInAppID){
            self.hideProView()
        }else{
            self.showProView()
        }
    }
    
    private func checkAndStartDownload() {
        guard !self.downloadLinkTextField.stringValue.isEmpty
            else {
                return
        }
        
        guard  self.downloadLinkTextField.stringValue.isValidUrl
            else{
                showErorr(title: "invalid Url", message: "Download link is not valid, please enter valid download link and try again")
                return
        }
        
        self.headerActionDelgate?.didSelectedStartDownloadFromHeader(downloadUrl: self.downloadLinkTextField.stringValue)
    }
    
    private func showErorr(title:String, message:String) {
        let alert =  NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
    
    private func hideProView() {
        widthOfProView.constant = 0
    }
    
    private func showProView() {
        widthOfProView.constant = 94
    }
    
    func didClickedProView() {
        showProWindow()
    }
    
    final func showProWindow(){
        proWindowController?.close()
        proWindowController = nil
        proWindowController = IDMProWindowController(windowNibName: "IDMProWindowController")
        proWindowController?.contentViewController = IDMProDemoController()
        let rect = NSMakeRect(self.view.window!.frame.minX + 220, self.view.window!.frame.maxY - (625) , 475, 550)
        self.proWindowController!.window!.setFrame(rect, display: true)
        self.proWindowController!.window!.makeKeyAndOrderFront(self)
    }
    
}
