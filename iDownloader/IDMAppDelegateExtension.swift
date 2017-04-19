//
//  IDMAppDelegateExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 08/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

extension AppDelegate {
    
    @IBAction func didSelectedSendMailToDeveloper(sender:Any?){
        let emailBody           = "(Write your message here)"
        let emailService        =  NSSharingService.init(named: NSSharingServiceNameComposeEmail)!
        emailService.recipients = ["codekiddies@gmail.com"]
        emailService.subject    = "iDownloader Support"
        
        if emailService.canPerform(withItems: [emailBody]) {
            emailService.perform(withItems: [emailBody])
        } else {
            IDMUtilities.shared.showError(title: "Oops!!", information: "Looks like there is no app in this device tnat can send mail, Please write your mail to <codekiddies@gmail.com>")
            
        }
    }
    
    @IBAction func didSelectedDownloadSafariExtension(sender:Any?){
        NSWorkspace.shared().open(URL(string:"http://www.abhishekhq.com/safari/iDownloader.safariextz")!)
    }
    
    @IBAction func didSelectedAddChromeExtension(sender:Any?){
        let canOpen =  NSWorkspace.shared().open([URL(string:"https://chrome.google.com/webstore/detail/idownloader-launcher/nnckfbjfkpjkkgmejemjnbknnhjadpom/")!], withAppBundleIdentifier: "com.google.Chrome", options: NSWorkspaceLaunchOptions.default, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
        if !canOpen {
            IDMUtilities.shared.showError(title: "Oops!!", information: "Looks like Chrome is not installed in your Mac")
        }
    }
    
    @IBAction func didSelectedAddFirefoxExtension(sender:Any?){
        let canOpen =  NSWorkspace.shared().open([URL(string:"https://addons.mozilla.org/addon/idownloader-launcher/")!], withAppBundleIdentifier: "org.mozilla.firefox", options: NSWorkspaceLaunchOptions.default, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
        if !canOpen {
            IDMUtilities.shared.showError(title: "Oops!!", information: "Looks like firefox is not installed in your Mac")
        }
        
    }
}
