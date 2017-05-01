//
//  IDMProDemoController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 29/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa
import StoreKit

class IDMProDemoController: NSViewController {

    @IBOutlet weak var bigProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var percentDemp: NSTextField!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var segmentTitle: NSTextField!
    @IBOutlet weak var segmentDescription: NSTextField!
    @IBOutlet weak var supportDevelopememt: NSTextField!
    @IBOutlet weak var supportDevelopemtDescription: NSTextField!
    @IBOutlet weak var flagImage: NSImageView!
    @IBOutlet weak var buyProButton: IDMCustomGreenButton!
    @IBOutlet weak var priceLable: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        progressView.foreground = NSColor(IDMr: 65, g: 117, b: 5)
        percentDemp.textColor = NSColor(IDMr: 65, g: 117, b: 5)
        setProductDetails()
        NotificationCenter.default.addObserver(self, selector: #selector(IDMProDemoController.pruchaseFail),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperDidFailNotification),
                                               object: nil)
        IDMAnalyticsHelper.shared.logLaunchedProWindow()
    }
    
    override func viewDidAppear() {
        resetViewState()
        runAnimation()
    }
    
    final func pruchaseFail() {
        runInMainThread {
            self.bigProgressIndicator.stopAnimation(self)
            self.bigProgressIndicator.isHidden = true
        }
      
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
    
    private func setProductDetails() {
        if let product = IAPHelper.shared.moreThreadsProduct{
            progressIndicator.isHidden = true
            progressIndicator.stopAnimation(self)
            self.priceLable.isHidden = false
            let price = product.localizedPrice()
            self.priceLable.stringValue = "for one time purchase of " + price
            self.buyProButton.title = "Buy iDownloader pro for " + price
            self.buyProButton.changeTextColor(NSColor(IDMr: 86, g: 173, b: 104))
            self.buyProButton.layoutSubtreeIfNeeded()
        }else {
            getListOfProducts()
        }
    }
    
    @IBAction func didSelectedBuyPro(_ sender: Any) {
        IDMAnalyticsHelper.shared.logLaunchedClickedBuy()
        bigProgressIndicator.isHidden = false
        bigProgressIndicator.startAnimation(self)
        if let iapProduct = IAPHelper.shared.moreThreadsProduct {
             IAPHelper.shared.buyProduct(iapProduct)
        }else {
            bigProgressIndicator.isHidden = true
            bigProgressIndicator.stopAnimation(self)
            getListOfProducts()
        }
       
    }
    
    @IBAction func didSelectedRestorePurchase(_ sender: Any) {
        bigProgressIndicator.isHidden = false
        bigProgressIndicator.startAnimation(self)
        IAPHelper.shared.restorePurchases()
    }
    
    
    final func getListOfProducts() {
        priceLable.isHidden = true
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)
        IAPHelper.shared.requestProducts { [weak self]
            (success, productArray)
            in
            guard let blockSelf = self
                else{
                    return
            }
            runInMainThread {
                blockSelf.progressIndicator.isHidden = true
                blockSelf.progressIndicator.stopAnimation(blockSelf)
                if let arrayOfProducts = productArray, arrayOfProducts.count > 0{
                    IAPHelper.shared.moreThreadsProduct = arrayOfProducts.last!
                    blockSelf.setProductDetails()
                }else {
                    IDMUtilities.shared.showError(title: "Oops!!", information: "Product details can't be fetched from server currently. Please try after sometime")
                }
            }
            
        }
    }
}
