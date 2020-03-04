//
//  JobsViewController.swift
//  Production Manager Pro
//
//  Created by James Goodliffe on 01/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa

class JobsViewController: NSViewController {
    //var windowFuncs = WindowFunctions(masterVC: (AppDelegate.getCurrentViewController()?.parent)!)
    @IBOutlet weak var jobsTable: NSTableView!
    @IBOutlet weak var lblTitle: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateIn(_:)), name: .showDashboard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateOut(_:)), name: .hideDashboard, object: nil)
        viewDidAppear()
    }
    
    override func viewDidAppear() {
        hideAll()
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.lblTitle.animator().alphaValue = 1
            }, completionHandler: {
                //Animation complete ¯\_(ツ)_/¯
            })
        }
    }
    
    override func viewWillDisappear() {
        animateOut_local()
    }
    
    func animateOut_local(){
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.lblTitle.animator().alphaValue = 0
            }, completionHandler: {
                //Animation complete ¯\_(ツ)_/¯
            })
        }
    }

    func hideAll(){
        lblTitle.alphaValue = 0.0
    }
    
    @objc func animateIn(_ notification: Notification)-> Void{
        hideAll()
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.lblTitle.animator().alphaValue = 1
            }, completionHandler: {
                //Animation complete ¯\_(ツ)_/¯
            })
        }
    }
    
    @objc func animateOut(_ notification: Notification)-> Void{
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.lblTitle.animator().alphaValue = 0
            }, completionHandler: {
                //Animation complete ¯\_(ツ)_/¯
            })
        }
    }
    @IBAction func showPeopleClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .peopleTab))
//        windowFuncs.showPeople()
    }
    @IBAction func showMaintenanceClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .maintenanceTab))
//        windowFuncs.showMaintenance()
    }
    @IBAction func showAssetsClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .assetsTab))

//        windowFuncs.showAssets()
    }
    @IBAction func showJobsClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .jobsTab))

//        windowFuncs.showJobs()
    }
    @IBAction func showLogisticsClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .logisticsTab))
//        windowFuncs.showLogistics()
    }
    
}
