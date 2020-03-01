//
//  LogisticsViewController.swift
//  Production Manager Pro
//
//  Created by James Goodliffe on 01/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa

class LogisticsViewController: NSViewController {
    
    var windowFunctions = WindowFunctions()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func btnAssetsClicked(_ sender: Any) {
        windowFunctions.showAssets()
    }
    @IBAction func btnJobsClicked(_ sender: Any) {
        windowFunctions.showJobs()
    }
    @IBAction func btnLogisticsClicked(_ sender: Any) {
        windowFunctions.showLogistics()
    }
    @IBAction func btnMaintenanceClicked(_ sender: Any) {
        windowFunctions.showMaintenance()
    }
    @IBAction func btnPeopleClicked(_ sender: Any) {
        windowFunctions.showPeople()
    }
}
