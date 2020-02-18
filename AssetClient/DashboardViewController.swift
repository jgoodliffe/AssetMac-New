//
//  DashboardViewController.swift
//  AssetClient
//
//  Created by James Goodliffe on 15/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit
import Alamofire
import SwiftyJSON

class DashboardViewController: NSViewController {
        
    @IBOutlet weak var Sidepanel: NSView!
    @IBOutlet var mainView: NSView!
    @IBOutlet weak var leftView: NSVisualEffectView!
    @IBOutlet weak var titleText: NSTextField!
    @IBOutlet weak var dateText: NSTextField!
    @IBOutlet weak var welcomeText: NSTextField!
    @IBOutlet weak var btnAssets: NSButton!
    @IBOutlet weak var btnJobs: NSButton!
    @IBOutlet weak var btnLogistics: NSButton!
    @IBOutlet weak var btnMaintenance: NSButton!
    @IBOutlet weak var btnPeople: NSButton!
    
    //Progress Indicator
    var mainIndicator = ProgressHUD.self
    
    //Operation Queue
    lazy var apiQueue: OperationQueue = {
      var apiQueue = OperationQueue()
      apiQueue.name = "Download queue"
      apiQueue.maxConcurrentOperationCount = 1
      return apiQueue
    }()
    
    //Data Request Flag
    var requestingData = false
    
    //Alamofire Information
    let port: String = "8080"
    var host: String = ""
    var userID: String = ""
    var manager = Alamofire.Session.default
    let configuration = URLSessionConfiguration.default
    
    //Token Stores + App Delegate Declaration
    let appDelegate = NSApp.delegate as? AppDelegate
    private let context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
    private var tokenStore:[NSManagedObject] = []
    private var requestToken = ""
    
    //User Information
    var firstName = ""
    
    /**
     Load all required content for the window to be useful.
     */
    func loadInitialWindowContents(){
        hideWindowContentsBeforeLoad()
        
        //Start Progress Indicator
        mainIndicator.setDefaultStyle(.light)
        mainIndicator.setContainerView(leftView)
        mainIndicator.setDefaultMaskType(.clear )
        mainIndicator.setFont(NSFont.init(name: "SF Pro Display Light", size: 35.0) ?? NSFont.systemFont(ofSize: 35.0))
        mainIndicator.show(withStatus: "Loading Dashboard")
        
        self.dateText.stringValue = getDate()
        
        getDashboardData(hostName: host, authToken: requestToken, success: {(response)-> Void in
            if response{
                //Content Fetch Complete
                DispatchQueue.main.async {
                    self.mainIndicator.dismiss(delay: 0.25)
                    let greeting = self.getStartOfGreeting() + self.firstName + "!"
                    self.welcomeText.stringValue = greeting
                    NSAnimationContext.runAnimationGroup({ (context) in
                        //Animation Duration
                        context.duration = 1.5
                        //What is being animated:
                        self.titleText.animator().alphaValue = 1
                        self.dateText.animator().alphaValue = 1
                        self.welcomeText.animator().alphaValue = 1
                        self.btnAssets.animator().alphaValue = 1
                        self.btnJobs.animator().alphaValue = 1
                        self.btnLogistics.animator().alphaValue = 1
                        self.btnMaintenance.animator().alphaValue = 1
                        self.btnPeople.animator().alphaValue = 1
                    }, completionHandler: {
                        //Animation complete ¯\_(ツ)_/¯
                    })
                }
            }
        }, failure: {(error)-> Void in
            DispatchQueue.main.async {
                //self.mainIndicator.dismiss()
                self.mainIndicator.setFont(NSFont.init(name: "SF Pro Display", size: 18.0) ?? NSFont.systemFont(ofSize: 18.0))
                self.mainIndicator.showErrorWithStatus("There was a problem loading the data.")
            }
        })
    }
    
    func getName(hostName: String, headers:HTTPHeaders, success: @escaping (_ response: Bool)-> Void, failure: @escaping (_ error: String) -> Void){
        let requestURL = hostName + ":" + port + "/person/" + userID
        manager.request(requestURL, method: .get, headers: headers).responseJSON { response in
            switch response.result{
            case.success(let jsonResponse):
                if let JSON = jsonResponse as? [String:Any]{
                    if let firstName = JSON["firstname"] as? String{
                        self.firstName = firstName
                        success(true)
                    }
                    else{
                        failure("Could not get a first name.")
                    }
                }
                else{
                    failure("Fail")
                }
            case.failure(let error):
                ///Deciper error before returning.
                let errorCode:Int = error.responseCode ?? 0
                let errorMessage:String = error.localizedDescription
                debugPrint("========Error=======")
                debugPrint(errorCode)
                debugPrint(errorMessage)
                if let data = response.data, let str = String(data: data, encoding: .utf8){
                    debugPrint("Server Error: "+str)
                    failure("Server Error")
                }
                if let data = response.data, let code = Int?(response.response?.statusCode ?? 0){
                    debugPrint("Response Status Code: "+String(code))
                    failure("Invalid Response")
                }
            }
        }
    }
    
    func getDashboardData(hostName: String, authToken: String, success: @escaping (_ response: Bool)-> Void, failure: @escaping (_ error: String)-> Void){
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        
        self.manager = Alamofire.Session(configuration:configuration)
        
        let headers:HTTPHeaders = [
            "token": authToken]
        
        let downloadOperation = BlockOperation{
            //When All operations complete, call success case.
        }
        downloadOperation.addExecutionBlock {
            self.getName(hostName: hostName, headers: headers, success: {(response)-> Void in
                if response{
                    //Run next Operation.
                    success(true)
                    return
                }
            },failure: {(error)-> Void in
                failure("Failed to complete Name Fetch operation")
            })
        }
        apiQueue.addOperation(downloadOperation)
    }
    
    func getStartOfGreeting() -> String{
        var greeting = String()
        let hour = Calendar.current.component(.hour, from: Date())
        
        
        switch hour {
        case _ where hour < 12:
            greeting = "Good Morning, "
        case _ where hour >= 12 && hour < 17 :
            greeting = "Good Afternoon, "
        case _ where hour >= 17:
            greeting = "Good Evening, "
        default:
            print("this is impossible")
        }
        
        return greeting
    }
    
    func getDate() -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        //OR dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let currentDateString: String = dateFormatter.string(from: date)
        return currentDateString
    }
    
    func hideWindowContentsBeforeLoad(){
        titleText.alphaValue = 0
        dateText.alphaValue = 0
        welcomeText.alphaValue = 0
        btnAssets.alphaValue = 0
        btnJobs.alphaValue = 0
        btnLogistics.alphaValue = 0
        btnMaintenance.alphaValue = 0
        btnPeople.alphaValue = 0
    }
    
    /**
     Gets the most recent authentication token and host from CoreData.
     */
    func retrieveTokenAndHost(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthStore")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        do{
            tokenStore = try context.fetch(request) as! [NSManagedObject]
            if let tokens = tokenStore as? [AuthStore] {
                //Get first array item
                if let token = tokens.first {
                    requestToken = token.token ?? "invalidTokenRequest"
                    host = token.host ?? "http://localhost"
                    userID = token.userID ?? "0"
                }
            }
        } catch{
            debugPrint("Failed to pull CoreData")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate?.enableMenuButtons()
        retrieveTokenAndHost()
        loadInitialWindowContents()
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.callPasswordChangeSegue(_:)), name: .changePasswordPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.closeWindow(_:)), name: .changedUserPassword, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.logOut(_:)), name: .logOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.animateIn(_:)), name: .showDashboard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.animateOut(_:)), name: .hideDashboard, object: nil)

    }
    
    /**
        Reduces the visibility of objects and animates them out
     */
    @objc func animateOut(_ notification: Notification)->Void{
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.titleText.animator().alphaValue = 0.2
                self.dateText.animator().alphaValue = 0.2
                self.welcomeText.animator().alphaValue = 0.2
                self.btnAssets.animator().alphaValue = 0.2
                self.btnJobs.animator().alphaValue = 0.2
                self.btnLogistics.animator().alphaValue = 0.2
                self.btnMaintenance.animator().alphaValue = 0.2
                self.btnPeople.animator().alphaValue = 0.2
            }, completionHandler: {
                //Animation complete ¯\_(ツ)_/¯
            })
        }
    }
    
    /**
        Improves the visibility of objects and animates them in
     */
    @objc func animateIn(_ notification: Notification)->Void{
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.titleText.animator().alphaValue = 1
                self.dateText.animator().alphaValue = 1
                self.welcomeText.animator().alphaValue = 1
                self.btnAssets.animator().alphaValue = 1
                self.btnJobs.animator().alphaValue = 1
                self.btnLogistics.animator().alphaValue = 1
                self.btnMaintenance.animator().alphaValue = 1
                self.btnPeople.animator().alphaValue = 1
            }, completionHandler: {
                //Animation complete ¯\_(ツ)_/¯
            })
        }
    }
    
    /**
     Notification Handler for log out function - triggered when the toolbar item is pressed.
     */
    @objc func logOut(_ notification: Notification){
        //Order of code execution is important here.
        if(view.window==NSApplication.shared.keyWindow){
            self.performSegue(withIdentifier: "logOut", sender: notification)
        }
        self.view.window?.close()
    }
    
    @objc func callPasswordChangeSegue(_ notification: Notification){
        //Only open Dialogue if window is key (active)!
        if(view.window==NSApplication.shared.keyWindow){
            self.performSegue(withIdentifier: "showChangePassword", sender: notification)
        }
    }
    
    @objc func closeWindow(_ notification: Notification){
        self.view.window?.close()
    }
    
    @IBAction func btnPeopleClicked(_ sender: Any) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
              // Use the value you want to animate to (NOT the starting value)
                self.btnPeople.animator().alphaValue = 0.75
            }, completionHandler:{
                self.btnPeople.animator().alphaValue = 1
            })
        }
    }
    @IBAction func btnMaintenanceClicked(_ sender: Any) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
              // Use the value you want to animate to (NOT the starting value)
                self.btnMaintenance.animator().alphaValue = 0.75
            }, completionHandler:{
                self.btnMaintenance.animator().alphaValue = 1
            })
        }
    }
    @IBAction func btnLogisticsClicked(_ sender: Any) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
              // Use the value you want to animate to (NOT the starting value)
                self.btnLogistics.animator().alphaValue = 0.75
            }, completionHandler:{
                self.btnLogistics.animator().alphaValue = 1
            })
        }
    }
    @IBAction func btnJobsClicked(_ sender: Any) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
              // Use the value you want to animate to (NOT the starting value)
                self.btnJobs.animator().alphaValue = 0.75
            }, completionHandler:{
                self.btnJobs.animator().alphaValue = 1
            })
        }
    }
    
    @IBAction func btnAssetsClicked(_ sender: Any) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
              // Use the value you want to animate to (NOT the starting value)
                self.btnAssets.animator().alphaValue = 0.75
            }, completionHandler:{
                self.btnAssets.animator().alphaValue = 1
            })
        }
    }
}
