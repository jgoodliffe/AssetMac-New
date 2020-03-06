//
//  CreateEventViewController.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 04/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit
import SwiftyJSON
import Alamofire

extension Notification.Name {
    static let refreshJobs = Notification.Name("refreshJobs")
}

class CreateEventViewController: NSViewController {

    @IBOutlet weak var comboEventType: NSComboBox!
    @IBOutlet weak var btnCreateEvent: NSButton!
    @IBOutlet weak var btnCancel: NSButton!
    @IBOutlet weak var txtEventName: NSTextField!
    @IBOutlet weak var txtStartTime: NSDatePicker!
    @IBOutlet weak var txtFinishTime: NSDatePicker!
    @IBOutlet weak var comboProjectManager: NSComboBox!
    @IBOutlet weak var comboClient: NSComboBox!
    @IBOutlet var txtNotes: NSTextView!
    @IBOutlet weak var lblInfo: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    //Alamofire Information
    let port: String = "8080"
    var host: String = ""
    var userID: String = ""
    var manager = Alamofire.Session.default
    let configuration = URLSessionConfiguration.default
    
    //Operation Queue
    lazy var apiQueue: OperationQueue = {
      var apiQueue = OperationQueue()
      apiQueue.name = "Download queue"
      apiQueue.maxConcurrentOperationCount = 1
      return apiQueue
    }()
    
    //Token Stores + App Delegate Declaration
    let appDelegate = NSApp.delegate as? AppDelegate
    private let context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
    private var tokenStore:[NSManagedObject] = []
    private var requestToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        retrieveTokenAndHost()
        populateProjectManagers()
        populateClients()
        populateEventTypes()
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
    
    @IBAction func btnCreateEventClicked(_ sender: Any) {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)
        btnCreateEvent.isEnabled = false
        if(fieldsValid()){
            createEvent()
        } else{
            lblInfo.textColor = NSColor.red
            lblInfo.stringValue = "Error: You left a field blank or dates were not input correctly!"
            progressIndicator.isHidden = true
            progressIndicator.stopAnimation(self)
            btnCreateEvent.isEnabled = true
        }
    }
    @IBAction func btnCancelClicked(_ sender: Any) {
        //Close window after a second pause.
        apiQueue.cancelAllOperations()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(self)
        }
    }
    
    func viewSetup(){
        btnCreateEvent.isEnabled = true
        txtStartTime.minDate = today()
        txtFinishTime.minDate = today()
        progressIndicator.isHidden = true
        self.comboEventType.completes = true
        self.comboEventType.removeAllItems()
        self.comboClient.completes = true
        self.comboClient.removeAllItems()
        self.comboProjectManager.completes = true
        self.comboProjectManager.removeAllItems()
    }
    
    func populateEventTypes(){
        let downloadOperation = BlockOperation{
            //When All operations complete, call success case.
        }
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        self.manager = Alamofire.Session(configuration:configuration)
        let headers:HTTPHeaders = [
            "token": requestToken]

        let requestURL = host + ":" + port + "/utilities/eventTypes"
        downloadOperation.addExecutionBlock {
            self.manager.request(requestURL, method: .post,headers: headers).responseJSON { response in
            switch response.result {
            case .failure( _):
                return
            case .success(let value):
                let jsonData = JSON(value)
                if jsonData["response-code"]==200 {
                    let eventTypes:[String] = jsonData["event-types"].arrayValue.map { $0.stringValue}
                    DispatchQueue.main.async {
                        self.comboEventType.addItems(withObjectValues: eventTypes ?? [])
                        self.comboEventType.selectItem(at: 1)
                    }
                } else{
                    debugPrint("Server Error: Failed to get Event Type Data")
                    self.dismiss(self)
                    return
                    }
                }
            }
        }
        apiQueue.addOperation(downloadOperation)
    }
    
    func populateProjectManagers(){
        
    }
    func populateClients(){
        
    }
    
    func today()-> Date{
        let date = Date()
        //let calendar = Calendar.current
        return date
    }
    
    func fieldsValid()-> Bool{
        //TODO: Check for selected Proj. Manager
        let eventName = txtEventName.stringValue
        let startTime = txtStartTime.dateValue
        let finishTime = txtFinishTime.dateValue
        let notes = txtNotes.string
        let projectManager = String(userID)
        if(eventName.isEmpty){
            return false
        }
        if(startTime<today()||finishTime<today()||finishTime<startTime){
            return false
        }
        return true
    }
    
    func formatDate(date:Date)-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func createEvent(){
        let eventName = txtEventName.stringValue
        let startTime = txtStartTime.dateValue
        let finishTime = txtFinishTime.dateValue
        let eventType = comboEventType.stringValue
        let notes = txtNotes.string
        let projectManager = String(userID)
        
        let downloadOperation = BlockOperation{
            //When All operations complete, call success case.
        }
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        self.manager = Alamofire.Session(configuration:configuration)
        let headers:HTTPHeaders = [
            "token": requestToken]
        let parameters:Parameters = [
            "request-type":"create",
            "eventName":eventName,
            "eventType":eventType,
            "startTime":formatDate(date: startTime),
            "finishTime":formatDate(date: finishTime),
            "notes":notes,
            "projectManager":projectManager
        ]
        let requestURL = host + ":" + port + "/events/"
        downloadOperation.addExecutionBlock {
            self.manager.request(requestURL, method: .post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result {
            case .failure( _):
                return
            case .success(let value):
                let jsonData = JSON(value)
                //print(jsonData)
                if jsonData["response-code"]==200 {
                    DispatchQueue.main.async {
                        
                        //Close window after a second pause.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.progressIndicator.stopAnimation(self)
                            self.progressIndicator.isHidden = true
                            self.dismiss(self)
                            
                            //Notify Dashboard Window(s) to close...
                            NotificationCenter.default.post(Notification(name: .refreshJobs))
                        }
                    }
                } else{
                    debugPrint("Server Error: Failed to create the event.")
                    self.progressIndicator.stopAnimation(self)
                    self.progressIndicator.isHidden = true
                    self.lblInfo.textColor = NSColor.red
                    self.lblInfo.stringValue = "Error: An unexpected error occurred while creating the event."
                    self.btnCreateEvent.isEnabled = true
                    return
                    }
                }
            }
        }
        apiQueue.addOperation(downloadOperation)
        
    }
}
