//
//  IDMSettingsContainer.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 24/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Cocoa

internal enum SettingsToolBarState{
    case generalSettings, schedulerSettings, tagsSettings, authSettings
}
class IDMSettingsContainer: NSViewController {  
    @IBOutlet weak var generalSettingsButton: NSButton!
    @IBOutlet weak var schdulerSettingsButton: NSButton!
    @IBOutlet weak var tagsSettingsButton: NSButton!
    @IBOutlet weak var authorizationSettingsButton: NSButton!
    @IBOutlet weak var settingsContainerView: NSView!
    var currentSubController:NSViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        setInitialButtonsState()
    }
    
    override func viewDidAppear() {
         didSelectedGeneralSettings(self)
    }
    
    private func setInitialButtonsState() {
        generalSettingsButton.image = NSImage(named:"GeneralSettings")!
        schdulerSettingsButton.image = NSImage(named: "schedulerSettings")!
        tagsSettingsButton.image = NSImage(named: "tagsSettings")!
        authorizationSettingsButton.image = NSImage(named: "AuthSettings")!
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
    
    
    @IBAction func didSelectedTagsSettings(_ sender: Any) {
        switchToSettingsState(state: SettingsToolBarState.tagsSettings)
        currentSubController = nil
    }
    
    @IBAction func didSelectedAuthorizationSettings(_ sender: Any) {
        switchToSettingsState(state: SettingsToolBarState.authSettings)
        currentSubController = nil
    }
    
    private func switchToSettingsState(state:SettingsToolBarState){
        setInitialButtonsState()
        switch state{
        case .authSettings:
            authorizationSettingsButton.image = NSImage(named: "AuthSettingsBlue")
        case .generalSettings:
            generalSettingsButton.image = NSImage(named: "GeneralSettingsBlue")
        case .tagsSettings:
            tagsSettingsButton.image = NSImage(named: "tagsSettingsBlue")
        case .schedulerSettings:
            schdulerSettingsButton.image = NSImage(named: "schedulerSettingsBlue")
        }
    }
    
    
    
}
