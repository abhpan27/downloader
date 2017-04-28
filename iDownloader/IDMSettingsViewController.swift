//
//  IDMSettingsViewController.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 28/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

class IDMSettingsViewController: NSViewController {

    @IBOutlet weak var weekDaysContainer: NSView!
    @IBOutlet weak var startTimeDatePicker: NSDatePicker!
    @IBOutlet weak var stopTimePicker: NSDatePicker!
    @IBOutlet weak var dailyCheckBox: NSButton!
    @IBOutlet weak var saturdayCheckbox: NSButton!
    @IBOutlet weak var fridayCheckBox: NSButton!
    @IBOutlet weak var thursdayCheckbox: NSButton!
    @IBOutlet weak var wednesdayCheckBox: NSButton!
    @IBOutlet weak var tuesdayCheckBox: NSButton!
    @IBOutlet weak var mondayCheckBox: NSButton!
    @IBOutlet weak var sundayCheckBox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpIntialUI()
        // Do view setup here.
    }
    
    private func setUpIntialUI() {
        
        if IDMSettingsManager.shared.shouldRunSchedulerDaily {
            dailyCheckBox.state = NSOnState
            weekDaysContainer.isHidden = true
        }else {
            dailyCheckBox.state = NSOffState
            weekDaysContainer.isHidden = false
        }
        
        let arrayOfWeekDays = IDMSettingsManager.shared.defaultSheduledWeekDays
        arrayOfWeekDays.contains(1) ? (sundayCheckBox.state = NSOnState) : (sundayCheckBox.state = NSOffState)
        arrayOfWeekDays.contains(2) ? (mondayCheckBox.state = NSOnState) : (mondayCheckBox.state = NSOffState)
        arrayOfWeekDays.contains(3) ? (tuesdayCheckBox.state = NSOnState) : (tuesdayCheckBox.state = NSOffState)
        arrayOfWeekDays.contains(4) ? (wednesdayCheckBox.state = NSOnState) : (wednesdayCheckBox.state = NSOffState)
        arrayOfWeekDays.contains(5) ? (thursdayCheckbox.state = NSOnState) : (thursdayCheckbox.state = NSOffState)
        arrayOfWeekDays.contains(6) ? (fridayCheckBox.state = NSOnState) : (fridayCheckBox.state = NSOffState)
        arrayOfWeekDays.contains(7) ? (saturdayCheckbox.state = NSOnState) : (saturdayCheckbox.state = NSOffState)
        
        startTimeDatePicker.dateValue = IDMSettingsManager.shared.defaultSchedulerStartDate
        stopTimePicker.dateValue = IDMSettingsManager.shared.defaultSchedulerStopDate
     
    }
    
    override func viewDidAppear() {
        changeWindowSize()
    }
    
    
    fileprivate func changeWindowSize(){
        if self.view.window == nil{
            return
        }
        let currentWindowRect = self.view.window!.frame
        let newWindowHeight:CGFloat = 300
        let newMinY = currentWindowRect.minY + (currentWindowRect.height - newWindowHeight)
        let newRect = NSMakeRect(currentWindowRect.minX, newMinY, currentWindowRect.width, newWindowHeight)
        self.view.window?.setFrame(newRect, display: false, animate: true)
    }
    
    @IBAction func didChangedStartTime(_ sender: Any) {
        let picker = sender as! NSDatePicker
        guard stopTimePicker.dateValue > picker.dateValue else{
            IDMUtilities.shared.showError(title: "Oops!!", information: "Scheduler stop time should not be smaller than scheduler start time")
            return
        }
        IDMSettingsManager.shared.setStartSchedulerTime(time: picker.dateValue)
    }
    
    @IBAction func didChangedStopTime(_ sender: Any) {
        let picker = sender as! NSDatePicker
        guard startTimeDatePicker.dateValue < picker.dateValue else{
            IDMUtilities.shared.showError(title: "Oops!!", information: "Scheduler stop time should not be smaller than scheduler start time")
            return
        }
        
        IDMSettingsManager.shared.setStopSchedulerTime(time: picker.dateValue)
    }
    
    @IBAction func didChangedRunDaily(_ sender: Any) {
        let button = sender as! NSButton
        if button.state == NSOnState {
            IDMSettingsManager.shared.setDefaultValueForShouldRunSchedulerDaily(value: true)
            weekDaysContainer.isHidden = true
        }else {
            IDMSettingsManager.shared.setDefaultValueForShouldRunSchedulerDaily(value: false)
            weekDaysContainer.isHidden = false
        }
    }
    
    @IBAction func didChangedSunday(_ sender: Any) {
        checkAndSetWeekDay(weekDay: 1, sender: sender)
    }
    
    @IBAction func didChangedMonday(_ sender: Any) {
        checkAndSetWeekDay(weekDay: 2, sender: sender)
    }
    
    @IBAction func didChangedTuesDay(_ sender: Any) {
        checkAndSetWeekDay(weekDay: 3, sender: sender)
    }
    
    @IBAction func didChangedWendesDay(_ sender: Any) {
        checkAndSetWeekDay(weekDay: 4, sender: sender)
    }
    
    @IBAction func didChangedThursday(_ sender: Any) {
        checkAndSetWeekDay(weekDay: 5, sender: sender)
    }
    
    @IBAction func didChangedFriday(_ sender: Any) {
        checkAndSetWeekDay(weekDay: 6, sender: sender)
    }
    
    @IBAction func didChangedSaturday(_ sender: Any) {
        checkAndSetWeekDay(weekDay: 7, sender: sender)
    }
    
    private func checkAndSetWeekDay(weekDay:Int, sender:Any){
        let button = sender as! NSButton
        var arrayOfItems = IDMSettingsManager.shared.defaultSheduledWeekDays
        if button.state == NSOnState {
            if !arrayOfItems.contains(weekDay){
                arrayOfItems.append(weekDay)
            }
        }else {
            if let index = arrayOfItems.index(of: weekDay) {
                arrayOfItems.remove(at: index)
            }
        }
        
        IDMSettingsManager.shared.setSchedulerWeekDays(weekDays: arrayOfItems)
    }
    
    
    
    
}
