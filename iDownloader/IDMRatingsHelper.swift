//
//  IDMRatingsHelper.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 23/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

final class IDMRatingsHelper {
    
    func shouldShowRatingsPopUp() -> Bool{
        if (NSApp.delegate as! AppDelegate).appController.parentController.downloadListController.fileDownloaders.count >= 2 {
            if !IDMSettingsManager.shared.hasAlreadyRated && !IDMSettingsManager.shared.hasSeletectedNotAskRatings{
                return true
            }
        }
        return false
    }
    
}
