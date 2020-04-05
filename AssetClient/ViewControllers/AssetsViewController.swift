//
//  AssetsViewController.swift
//  Production Manager Pro
//
//  Created by James Goodliffe on 01/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire
import AppKit

class AssetsViewController: NSViewController {
    //var windowFuncs = WindowFunctions(masterVC: (AppDelegate.getCurrentViewController()?.parent)!)
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var btnNewAsset: NSButton!
    @IBOutlet weak var btnEditAsset: NSButton!
    @IBOutlet weak var btnDeleteAsset: NSButton!
    @IBOutlet weak var btnCategories: NSButton!
    @IBOutlet weak var btnQuality: NSButton!
    @IBOutlet weak var lblAssetName: NSTextField!
    @IBOutlet weak var lblDateAdded: NSTextField!
    @IBOutlet weak var lblInspectionDate: NSTextField!
    @IBOutlet weak var lblQuantity: NSTextField!
    @IBOutlet weak var imgAssetView: NSImageView!
    @IBOutlet weak var tblAssets: NSTableView!
    @IBOutlet weak var comboSubCategory: NSComboBox!
    @IBOutlet weak var comboCategory: NSComboBox!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var leftView: NSVisualEffectView!
    let assetsTD = AssetsTD()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateIn(_:)), name: .showDashboard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateOut(_:)), name: .hideDashboard, object: nil)
        tblAssets.dataSource = assetsTD
        tblAssets.delegate = assetsTD
        retrieveTokenAndHost()
        hideAll()
        loadInitialWindowContents()
    }
    
    //Progress Indicator
    var mainIndicator = ProgressHUD.self

    //Assets
    var assets:[Assets] = []
    var selectedID:Int = 0

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
    
    override func viewDidAppear() {
        hideAll()
        refreshView()
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
        btnNewAsset.alphaValue = 0.0
        btnQuality.alphaValue = 0.0
        btnDeleteAsset.alphaValue = 0.0
        btnCategories.alphaValue = 0.0
        btnEditAsset.alphaValue = 0.0
        lblAssetName.alphaValue = 0.0
        lblDateAdded.alphaValue = 0.0
        lblInspectionDate.alphaValue = 0.0
        lblQuantity.alphaValue = 0.0
        imgAssetView.alphaValue = 0.0
        tblAssets.alphaValue = 0.0
        comboCategory.alphaValue = 0.0
        comboSubCategory.alphaValue = 0.0
        searchField.alphaValue = 0.0
    }
    
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
    
    func refreshView(){
        getInitialAssetsData(hostName: host, authToken: requestToken, success: {(response)-> Void in
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
                print(error)
            }
        })
    }
    
    func loadInitialWindowContents(){
        tblAssets.usesAlternatingRowBackgroundColors = true
        tblAssets.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle

        //Start Progress Indicator
        mainIndicator.setDefaultStyle(.light)
        mainIndicator.setContainerView(leftView)
        mainIndicator.setDefaultMaskType(.clear )
        mainIndicator.setFont(NSFont.init(name: "SF Pro Display Light", size: 35.0) ?? NSFont.systemFont(ofSize: 35.0))
        mainIndicator.show(withStatus: "Loading Jobs")
        
        getInitialAssetsData(hostName: host, authToken: requestToken, success: {(response)-> Void in
            if response{
                self.animateIn_local()
                DispatchQueue.main.async {
                    self.mainIndicator.dismiss(delay: 0.25)
                }
            }
        }, failure: {(error)-> Void in
            DispatchQueue.main.async {
                self.mainIndicator.setFont(NSFont.init(name: "SF Pro Display", size: 18.0) ?? NSFont.systemFont(ofSize: 18.0))
                self.mainIndicator.showErrorWithStatus("There was a problem loading the data.")
            }
        })
    }
    
    func getInitialAssetsData(hostName: String, authToken: String, success: @escaping (_ response: Bool)-> Void, failure: @escaping (_ error: String)-> Void){
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        
        self.manager = Alamofire.Session(configuration:configuration)
        
        let headers:HTTPHeaders = [
            "token": authToken]
        
        let downloadOperation = BlockOperation{
            //When All operations complete, call success case.
        }
        downloadOperation.addExecutionBlock {
            self.getAllAssets(hostName: hostName, headers: headers, success: {(response)-> Void in
                if response{
                    success(true)
                    return
                }
            },failure: {(error)-> Void in
                failure("Failed to complete Name Fetch operation")
            })
        }
        apiQueue.addOperation(downloadOperation)
    }
    
    func getAllAssets(hostName: String, headers:HTTPHeaders, success: @escaping (_ response: Bool)-> Void, failure: @escaping (_ error: String) -> Void){
            let requestURL = hostName + ":" + port + "/assets/all"
            manager.request(requestURL, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .failure( _):
                failure("Other failure.")
                return
            case .success(let value):
                let jsonData = JSON(value)
                if let assetArray = jsonData["assets"].array {
                    self.populateTable(assetArray: assetArray)
                    success(true)
                } else{
                    debugPrint("Failed to get target data from Server.")
                    failure("Failed to get target data from Server.")
                    return
                    }
                }
            }
        }
    
    func populateTable(assetArray: [JSON]){
            assets.removeAll()
            for asset in assetArray{
                guard let id = asset["id"].int else { return }
                guard let name = asset["name"].string else{ return }
                guard let quantity = asset["quantity"].int else { return }
                guard let value = asset["value"].int else{ return }
                guard let dateAdded = asset["dateAdded"].string else{ return }
                guard let inspectionDue = asset["inspectionDue"].string else{ return }
                guard let category = asset["category"].string else{ return }
                guard let subCategory = asset["subCategory"].string else{ return }
                let newAsset = Assets(id: id, name: name, quantity: quantity, value: value, dateAdded: dateAdded, inspectionDue: inspectionDue, category: category, subCategory: subCategory)
                assets.append(newAsset)
            }
        self.tblAssets.reloadData()
            
            for singleEvent in assets{
    //            getProjectManager(id: singleEvent.projectManagerID, success: { (response)->Void in
    //                let projectManagerName = response
    //                singleEvent.projectManager = projectManagerName
    //                self.jobsTable.reloadData()
    //            }, failure: {(error)-> Void in
    //
    //            })
            }
        }
    

    
    @objc func animateIn(_ notification: Notification)-> Void{
        hideAll()
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1.5
                //What is being animated:
                self.lblTitle.animator().alphaValue = 1
                self.btnNewAsset.animator().alphaValue = 1
                self.btnQuality.animator().alphaValue = 1
                self.btnDeleteAsset.animator().alphaValue = 1
                self.btnCategories.animator().alphaValue = 1
                self.btnEditAsset.animator().alphaValue = 1
                self.lblAssetName.animator().alphaValue = 1
                self.lblDateAdded.animator().alphaValue = 1
                self.lblInspectionDate.animator().alphaValue = 1
                self.lblQuantity.animator().alphaValue = 1
                self.imgAssetView.animator().alphaValue = 1
                self.tblAssets.animator().alphaValue = 1
                self.comboCategory.animator().alphaValue = 1
                self.comboSubCategory.animator().alphaValue = 1
                self.searchField.animator().alphaValue = 1
            }, completionHandler: {
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
                self.btnNewAsset.animator().alphaValue = 1
                self.btnQuality.animator().alphaValue = 1
                self.btnDeleteAsset.animator().alphaValue = 1
                self.btnCategories.animator().alphaValue = 1
                self.btnEditAsset.animator().alphaValue = 1
                self.lblAssetName.animator().alphaValue = 1
                self.lblDateAdded.animator().alphaValue = 1
                self.lblInspectionDate.animator().alphaValue = 1
                self.lblQuantity.animator().alphaValue = 1
                self.imgAssetView.animator().alphaValue = 1
                self.tblAssets.animator().alphaValue = 1
                self.comboCategory.animator().alphaValue = 1
                self.comboSubCategory.animator().alphaValue = 1
                self.searchField.animator().alphaValue = 1
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
                self.btnNewAsset.animator().alphaValue = 0
                self.btnQuality.animator().alphaValue = 0
                self.btnDeleteAsset.animator().alphaValue = 0
                self.btnCategories.animator().alphaValue = 0
                self.btnEditAsset.animator().alphaValue = 0
                self.lblAssetName.animator().alphaValue = 0
                self.lblDateAdded.animator().alphaValue = 0
                self.lblInspectionDate.animator().alphaValue = 0
                self.lblQuantity.animator().alphaValue = 0
                self.imgAssetView.animator().alphaValue = 0
                self.tblAssets.animator().alphaValue = 0
                self.comboCategory.animator().alphaValue = 0
                self.comboSubCategory.animator().alphaValue = 0
                self.searchField.animator().alphaValue = 0
            }, completionHandler: {
            })
        }
    }
    @IBAction func peopleClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .peopleTab))
        //windowFuncs.showPeople()
    }
    @IBAction func maintenanceClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .maintenanceTab))

        //windowFuncs.showMaintenance()
    }
    @IBAction func logisticsClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .logisticsTab))
       // windowFuncs.showLogistics()
    }
    @IBAction func jobsClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .jobsTab))

//        windowFuncs.showJobs()
    }
    @IBAction func assetsClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .assetsTab))
//        windowFuncs.showAssets()
    }
    
}
