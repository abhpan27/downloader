//
//  IDMSettingsController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 27/03/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

struct SettingsKeys {
    static let shouldShowNotificationOnDownload = "shouldShowNotificationOnDownload"
    static let notificationSound = "notificationSound"
    static let defaultBookMarkData = "defaultBookMarkData"
    static let noOfSegmennts = "numberOfSegments"
    static let isFreshInstall = "FreshInstall"
    static let hasAlreadyRatedApp = "hasAlreadyRatedApp"
    static let hasSeletectedNotAskRatings = "hasSeletectedNotAskRatings"
    static let shouldRunSchedulerDaily = "shouldRunSchedulerDaily"
    static let scheduledWeekDays = "scheduledWeekDays"
    static let userDeviceIDHash = "userDeviceIDHash"
    static let schedulerStartTime = "schedulerStartTime"
    static let schedulerStopTime = "schedulerStopTime"
}

class IDMSettingsController: NSViewController {

   
    @IBOutlet weak var shouldShowNotificationCheckBox: NSButton!
    @IBOutlet weak var downloadLoactionLabel: NSTextField!
    @IBOutlet weak var notificationSoundPopUp: NSPopUpButton!
    @IBOutlet weak var numberOfSegmentsPopup: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        readDataFromUserDefaultsAndSetUpUI()
    }
    override func viewDidAppear() {
        runInMainThread {
            self.changeWindowSize()
        }
    }
    private func readDataFromUserDefaultsAndSetUpUI() {
        setShouldShowNotifcation()
        setNotificationSound()
        setDefaultDownloadLocation()
        setUpNoOfSegments()
    }
    
    fileprivate func changeWindowSize(){
        if self.view.window == nil{
            return
        }
        let currentWindowRect = self.view.window!.frame
        let newWindowHeight:CGFloat = 350
        let newMinY = currentWindowRect.minY + (currentWindowRect.height - newWindowHeight)
        let newRect = NSMakeRect(currentWindowRect.minX, newMinY, currentWindowRect.width, newWindowHeight)
        self.view.window?.setFrame(newRect, display: false, animate: true)
    }
    
    private func setShouldShowNotifcation() {
        if IDMSettingsManager.shared.shouldShowNotification {
            shouldShowNotificationCheckBox.state = NSOnState
        }else {
            shouldShowNotificationCheckBox.state = NSOffState
        }
    }
    
    private func setNotificationSound() {
        var listOfSounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]
        if  let soundListFromDevice = getListOfAvailableSounds(), soundListFromDevice.count > 0 {
            listOfSounds = soundListFromDevice
        }
        listOfSounds.insert(Constants.defaultSoundName, at: 0)
        self.notificationSoundPopUp.addItems(withTitles: listOfSounds)
        
        self.notificationSoundPopUp.selectItem(withTitle: IDMSettingsManager.shared.defaultNotificationSound)
    }
    
    private func getListOfAvailableSounds() -> [String]?{
        var soundNames = [String]()
        do {
            let dirFiles = try FileManager.default.contentsOfDirectory(atPath: "/System/Library/Sounds/")
            for file in dirFiles {
                soundNames.append((file as NSString).deletingPathExtension)
            }
        }
        catch (_){
        }
        return soundNames
    }
    
    private func setDefaultDownloadLocation() {
        self.downloadLoactionLabel.stringValue = IDMSettingsManager.shared.defaultDownloadPath
    }
    
    private func setUpNoOfSegments() {
        let noOfSegmentArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
        numberOfSegmentsPopup.addItems(withTitles: noOfSegmentArray)
        numberOfSegmentsPopup.selectItem(withTitle: "\(IDMSettingsManager.shared.defaultNumberOfSegments)")
    }
    
    @IBAction func didChangedShouldShowNotification(_ sender: Any) {
        let button = sender as! NSButton
        if button.state == NSOnState {
            IDMSettingsManager.shared.setDefaultValueForShouldShowNotification(value: true)
        }else {
             IDMSettingsManager.shared.setDefaultValueForShouldShowNotification(value: false)
        }
        setShouldShowNotifcation()
    }
    
    @IBAction func didChangeNotificationSound(_ sender: Any) {
        let popUpButton = sender as! NSPopUpButton
        if let title = popUpButton.titleOfSelectedItem{
             IDMSettingsManager.shared.setDefaultNotificationSound(sound: title)
            NSSound(named: title)?.play()
        }
        setNotificationSound()
    }
    
    @IBAction func didSelectedChangeDownloadLocation(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                guard let selectedURL = openPanel.url
                    else{
                        return
                }
                do {
                    let bookmarkData = try selectedURL.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    IDMSettingsManager.shared.setValueForDefaultBookMark(bookMark: bookmarkData)
                    self.setDefaultDownloadLocation()
                }catch  {
                    Swift.print(error)
                }
                
            }
        }
    }
    
    @IBAction func didChangedDefaultNoOfSegments(_ sender: Any) {
        let popUpButton = sender as! NSPopUpButton
        if let title = popUpButton.titleOfSelectedItem{
            if let value = Int(title){
                checkAndSetUpNumberOfSegments(forNumberOfSegemnts: value)
            }
        }
    }
    
    private func checkAndSetUpNumberOfSegments(forNumberOfSegemnts:Int) {
        if IAPHelper.shared.isProductPurchased(Constants.productInAppID){
            IDMSettingsManager.shared.setDefaultNumberOfSegments(segments: forNumberOfSegemnts)
        }else {
            if forNumberOfSegemnts <= Constants.defaultNumberOfSegments {
                IDMSettingsManager.shared.setDefaultNumberOfSegments(segments: forNumberOfSegemnts)
            }else {
                (NSApp.delegate as! AppDelegate).appController.parentController.headerController.showProWindow()
            }
        }
        setUpNoOfSegments()
    }
    
}
