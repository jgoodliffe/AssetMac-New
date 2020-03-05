//
//  JobsViewController.swift
//  Production Manager Pro
//
//  Created by James Goodliffe on 01/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit
import SwiftyJSON
import Alamofire

class JobsViewController: NSViewController {
    //var windowFuncs = WindowFunctions(masterVC: (AppDelegate.getCurrentViewController()?.parent)!)
    
    @IBOutlet weak var toggleActions: NSStackView!
    @IBOutlet weak var quickActions: NSStackView!
    @IBOutlet weak var switchShowAll: NSSwitch!
    @IBOutlet weak var btnNewEvent: NSButton!
    @IBOutlet weak var btnEditEvent: NSButton!
    @IBOutlet weak var btnDeleteEvent: NSButton!
    @IBOutlet weak var btnAssets: NSButton!
    @IBOutlet weak var btnSmartMatch: NSButton!
    @IBOutlet weak var jobsTableContainer: NSScrollView!
    @IBOutlet weak var jobsTable: NSTableView!
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var leftView: NSVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateIn(_:)), name: .showDashboard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateOut(_:)), name: .hideDashboard, object: nil)
        jobsTable.dataSource = self
        jobsTable.delegate = self
        retrieveTokenAndHost()
        viewDidAppear()
        loadInitialWindowContents()
        
    }
    
    //Progress Indicator
    var mainIndicator = ProgressHUD.self

    //Events
    var events:[Events] = []
    var selectedID:Int = 0
    
    //All or Upcoming
    var requestAllJobs: Bool = false

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

    //Button Handling
    @IBAction func newClicked(_ sender: Any) {
        performSegue(withIdentifier: "transitionToNewEvent", sender: nil)
    }
    @IBAction func editClicked(_ sender: Any) {
        performSegue(withIdentifier: "transitionToEditEvent", sender: nil)
    }
    @IBAction func deleteClicked(_ sender: Any) {
    }
    @IBAction func assetsClicked(_ sender: Any) {
    }
    @IBAction func smartMatchClicked(_ sender: Any) {
    }
    
    //Initial Loading
    override func viewDidAppear() {
        hideAll()
        refreshView()
    }
    
    override func viewWillDisappear() {
        animateOut_local()
    }
    
    @IBAction func switchToggle(_ sender: Any) {
        jobsTable.alphaValue = 0
        if switchShowAll.state == NSControl.StateValue.on{
            //Show All
            requestAllJobs = true
            loadInitialWindowContents()
        } else{
            //Show Upcoming
            requestAllJobs = false
            loadInitialWindowContents()
        }
    }
    func animateOut_local(){
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.lblTitle.animator().alphaValue = 0
                self.jobsTable.animator().alphaValue = 0
                self.jobsTableContainer.animator().alphaValue = 0
                self.toggleActions.animator().alphaValue = 0
                self.quickActions.animator().alphaValue = 0
            }, completionHandler: {
                //Animation complete ¯\_(ツ)_/¯
            })
        }
    }
    func animateIn_local(){
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.lblTitle.animator().alphaValue = 1
                self.jobsTable.animator().alphaValue = 1
                self.jobsTableContainer.animator().alphaValue = 1
                self.toggleActions.animator().alphaValue = 1
                self.quickActions.animator().alphaValue = 1
            }, completionHandler: {
                //Animation complete ¯\_(ツ)_/¯
            })
        }
    }

    func hideAll(){
        lblTitle.alphaValue = 0.0
        jobsTable.alphaValue = 0.0
        jobsTableContainer.alphaValue = 0.0
        toggleActions.alphaValue = 0.0
        quickActions.alphaValue = 0.0
        
        //disable buttons
        btnEditEvent.isEnabled = false
        btnDeleteEvent.isEnabled = false
        btnAssets.isEnabled = false
    }
    
    func enableButtons(){
        btnEditEvent.isEnabled = true
        btnDeleteEvent.isEnabled = true
        btnAssets.isEnabled = true
    }
    
    func disableButtons(){
        btnEditEvent.isEnabled = false
        btnDeleteEvent.isEnabled = false
        btnAssets.isEnabled = false
    }
    
    @objc func animateIn(_ notification: Notification)-> Void{
        hideAll()
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.lblTitle.animator().alphaValue = 1
                self.jobsTable.animator().alphaValue = 1
                self.jobsTableContainer.animator().alphaValue = 1
                self.toggleActions.animator().alphaValue = 1
                self.quickActions.animator().alphaValue = 1
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
                 self.jobsTable.animator().alphaValue = 0
                 self.jobsTableContainer.animator().alphaValue = 0
                 self.toggleActions.animator().alphaValue = 0
                 self.quickActions.animator().alphaValue = 0
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
    
    //General Functions
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
    
    func loadInitialWindowContents(){
        jobsTable.usesAlternatingRowBackgroundColors = true
        jobsTable.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle

        //Start Progress Indicator
        mainIndicator.setDefaultStyle(.light)
        mainIndicator.setContainerView(leftView)
        mainIndicator.setDefaultMaskType(.clear )
        mainIndicator.setFont(NSFont.init(name: "SF Pro Display Light", size: 35.0) ?? NSFont.systemFont(ofSize: 35.0))
        mainIndicator.show(withStatus: "Loading Jobs")
        
        getJobsData(hostName: host, authToken: requestToken, success: {(response)-> Void in
            if response{
                self.animateIn_local()
                DispatchQueue.main.async {
                    self.mainIndicator.dismiss(delay: 0.25)
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
    
    func getJobsData(hostName: String, authToken: String, success: @escaping (_ response: Bool)-> Void, failure: @escaping (_ error: String)-> Void){
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        
        self.manager = Alamofire.Session(configuration:configuration)
        
        let headers:HTTPHeaders = [
            "token": authToken]
        
        let downloadOperation = BlockOperation{
            //When All operations complete, call success case.
        }
        downloadOperation.addExecutionBlock {
            if(self.requestAllJobs){
                self.getAllJobs(hostName: hostName, headers: headers, success: {(response)-> Void in
                    if response{
                        //Run next Operation.
                        success(true)
                        return
                    }
                },failure: {(error)-> Void in
                    failure("Failed to complete Name Fetch operation")
                })
            } else{
                self.getUpcomingJobs(hostName: hostName, headers: headers, success: {(response)-> Void in
                    if response{
                        //Run next Operation.
                        success(true)
                        return
                    }
                },failure: {(error)-> Void in
                    failure("Failed to complete Name Fetch operation")
                })
            }
        }
        apiQueue.addOperation(downloadOperation)
    }
    
    func getAllJobs(hostName: String, headers:HTTPHeaders, success: @escaping (_ response: Bool)-> Void, failure: @escaping (_ error: String) -> Void){
            let requestURL = hostName + ":" + port + "/events/all"
            manager.request(requestURL, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .failure( _):
                failure("Other failure.")
                return
            case .success(let value):
                let jsonData = JSON(value)
                if let eventArray = jsonData["events"].array {
                    self.populateTable(eventArray: eventArray)
                    success(true)
                } else{
                    debugPrint("Failed to get target data from Server.")
                    failure("Failed to get target data from Server.")
                    return
                    }
                }
            }
        }
    
    func getUpcomingJobs(hostName: String, headers:HTTPHeaders, success: @escaping (_ response: Bool)-> Void, failure: @escaping (_ error: String) -> Void){
        let requestURL = hostName + ":" + port + "/events/upcoming"
        manager.request(requestURL, method: .get, headers: headers).responseJSON { response in
        switch response.result {
        case .failure( _):
            failure("Other failure.")
            return
        case .success(let value):
            let jsonData = JSON(value)
            if let eventArray = jsonData["events"].array {
                //print(eventArray)
                //print(eventArray.count)
//                for event in eventArray{
//                    print(event["id"])
//                    print(event)
//                }
                self.populateTable(eventArray: eventArray)
                success(true)
            } else{
                debugPrint("Failed to get target data from Server.")
                failure("Failed to get target data from Server.")
                return
                }
            }
        }
    }
    
    func populateTable(eventArray: [JSON]){
        events.removeAll()
        for event in eventArray{
            guard let id = event["id"].int else { return }
            guard let name = event["name"].string else { return }
            guard let startDate = event["startdate"].string else{ return }
            guard let endDate = event["enddate"].string else{ return }
            guard let notes = event["notes"].string else{ return }
            let newEvent = Events(id: id, name: name, startDate: startDate, endDate: endDate, notes: notes)
            events.append(newEvent)
        }
        self.jobsTable.reloadData()
    }
    
    func refreshView(){
        getJobsData(hostName: host, authToken: requestToken, success: {(response)-> Void in
            if response{
                self.animateIn_local()
                DispatchQueue.main.async {
                    self.mainIndicator.dismiss(delay: 0.25)
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
}

extension JobsViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (events.count)
    }
}

extension JobsViewController: NSTableViewDelegate{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
                
        let event = events[row]
        
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        
        switch tableColumn?.identifier.rawValue{
        case "eventName":
            cell.textField?.stringValue = event.name
        case "startDate":
            cell.textField?.stringValue = formatDate(date: event.startDate)
        case "endDate":
            cell.textField?.stringValue = formatDate(date: event.endDate)
        case "id":
            cell.textField?.stringValue = String(event.id)
        default:
            cell.textField?.stringValue = "-NONE-"
        }
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if jobsTable.selectedRowIndexes.count>0{
            self.enableButtons()
            let index:Int = jobsTable.selectedRow
            let numberOfColumns = jobsTable.numberOfColumns
            let cellView: NSTableCellView = jobsTable.view(atColumn: (numberOfColumns-1), row: index, makeIfNecessary: true) as! NSTableCellView
            selectedID = Int(cellView.textField?.stringValue ?? "") ?? 0
        } else{
            self.disableButtons()
        }
    }
    
    func formatDate(date:String)-> String{
        let dateformatterGet = DateFormatter()
        dateformatterGet.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateformatterPrint = DateFormatter()
        dateformatterPrint.dateFormat = "EE, MMM d, yyyy HH:mm"
        
        if let formattedDate = dateformatterGet.date(from: date){
            return dateformatterPrint.string(from: formattedDate)
        } else{
            return date
        }
    }
}
