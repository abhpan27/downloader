//
//  IDMSettingsContainer.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 24/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

internal enum SettingsToolBarState{
    case generalSettings, schedulerSettings
}
class IDMSettingsContainer: NSViewController {  
    @IBOutlet weak var generalSettingsButton: NSButton!
    @IBOutlet weak var schdulerSettingsButton: NSButton!
    @IBOutlet weak var settingsContainerView: NSView!
    var currentSubController:NSViewController?
    @IBOutlet weak var settingsContainer: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        settingsContainer.wantsLayer = true
        settingsContainer.layer?.borderWidth = 1.0
        settingsContainer.layer?.borderColor = NSColor(IDMr: 79, g: 79, b: 79).cgColor
        settingsContainer.layer?.cornerRadius = 5.0
        generalSettingsButton.wantsLayer = true
        schdulerSettingsButton.wantsLayer = true
        setInitialButtonsState()
    }
    
    override func viewDidAppear() {
         didSelectedGeneralSettings(self)
    }
    
    private func setInitialButtonsState() {
        generalSettingsButton.image = NSImage(named:"GeneralSettings")!
        schdulerSettingsButton.image = NSImage(named: "schedulerSettings")!
        generalSettingsButton.layer?.backgroundColor = NSColor.clear.cgColor
        schdulerSettingsButton.layer?.backgroundColor = NSColor.clear.cgColor
        for subview in self.settingsContainerView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func didSelectedGeneralSettings(_ sender: Any) {
        switchToSettingsState(state: SettingsToolBarState.generalSettings)
        currentSubController = IDMSettingsController()
        self.settingsContainerView.addFittingSubView(subView: currentSubController!.view)
    }
    
    
    @IBAction func didSelectedSchedulerSettings(_ sender: Any) {
        switchToSettingsState(state: SettingsToolBarState.schedulerSettings)
        currentSubController = nil
    }
    
    private func switchToSettingsState(state:SettingsToolBarState){
        setInitialButtonsState()
        switch state{
        case .generalSettings:
            generalSettingsButton.image = NSImage(named: "GeneralSettingsWhite")
            generalSettingsButton.layer?.backgroundColor = NSColor(IDMr: 79, g: 79, b: 79, alpha:0.8).cgColor
        case .schedulerSettings:
            schdulerSettingsButton.image = NSImage(named: "schedulerSettingsWhite")
            schdulerSettingsButton.layer?.backgroundColor = NSColor(IDMr: 79, g: 79, b: 79, alpha:0.8).cgColor
        }
    }
    
    
    
}
