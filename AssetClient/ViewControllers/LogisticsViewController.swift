//
//  LogisticsViewController.swift
//  Production Manager Pro
//
//  Created by James Goodliffe on 01/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa

class LogisticsViewController: NSViewController {
    
//    var windowFuncs = WindowFunctions(masterVC: (AppDelegate.getCurrentViewController()?.parent)!)

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
    
    @IBAction func btnAssetsClicked(_ sender: Any) {
//        windowFunctions.showAssets()
        NotificationCenter.default.post(Notification(name: .assetsTab))
    }
    @IBAction func btnJobsClicked(_ sender: Any) {
//        windowFunctions.showJobs()
        NotificationCenter.default.post(Notification(name: .jobsTab))

    }
    @IBAction func btnLogisticsClicked(_ sender: Any) {
//        windowFunctions.showLogistics()
        NotificationCenter.default.post(Notification(name: .logisticsTab))

    }
    @IBAction func btnMaintenanceClicked(_ sender: Any) {
//        windowFunctions.showMaintenance()
        NotificationCenter.default.post(Notification(name: .maintenanceTab))

    }
    @IBAction func btnPeopleClicked(_ sender: Any) {
//        windowFunctions.showPeople()
        NotificationCenter.default.post(Notification(name: .peopleTab))

    }
}
