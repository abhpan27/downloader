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
    
}
