//
//  IDMAnalyticsHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 01/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation
import Crashlytics

final class IDMAnalyticsHelper {
    
    static let shared = IDMAnalyticsHelper()
    
    let freshInstallKey = "Fresh Install"
    let locale = "Locale"
    let newDownload = "New Download"
    
    final func checkAndLogFreshInstall() {
        if IDMSettingsManager.shared.isFreshInstall {
            Answers.logCustomEvent(withName: freshInstallKey, customAttributes: [
                locale: Locale.current.regionCode as Any])
            IDMSettingsManager.shared.setIsFreshInstall()
        }
        
    }
    
    final func LogNewDownloadStart() {
        Answers.logCustomEvent(withName: newDownload)
    }
}
