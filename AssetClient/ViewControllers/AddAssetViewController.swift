//
//  AddAssetViewController.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 06/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class AddAssetViewController: NSViewController, NSComboBoxDelegate {

    @IBOutlet weak var comboAssetCategory: NSComboBox!
    @IBOutlet weak var comboAssetName: NSComboBox!
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
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(self)
    }
    @IBAction func addAssetClicked(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveTokenAndHost()
        comboAssetCategory.delegate = self
        comboAssetCategory.removeAllItems()
        comboAssetName.removeAllItems()
        comboAssetName.isEnabled = false
        comboAssetCategory.isEnabled = false
        progressIndicator.isHidden = true
        self.view.window?.appearance = NSAppearance(named: .darkAqua)
        loadCategories()
    }
    
    func loadCategories(){
        let downloadOperation = BlockOperation{
            //When All operations complete, call success case.
        }
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        self.manager = Alamofire.Session(configuration:configuration)
        let headers:HTTPHeaders = [
            "token": requestToken]

        let requestURL = host + ":" + port + "/assets/categories"
        downloadOperation.addExecutionBlock {
            self.manager.request(requestURL, method: .get,headers: headers).responseJSON { response in
            switch response.result {
            case .failure( _):
                return
            case .success(let value):
                let jsonData = JSON(value)
                print(jsonData)
                if jsonData["response-code"]==200 {
                    if jsonData["asset-types"].array != nil{
                        if let eventTypes:[String] = jsonData["asset-types"].arrayValue.map({ $0.stringValue}){
                            DispatchQueue.main.async {
                                self.comboAssetCategory.addItems(withObjectValues: eventTypes )
                                self.comboAssetCategory.selectItem(at: 1)
                                self.comboAssetCategory.isEnabled = true
                                self.updateSelection(selection: self.comboAssetCategory.stringValue)
                            }
                        } else{
                            self.comboAssetCategory.addItem(withObjectValue: "No Categories in database!")
                        }
                    }
                } else{
                    debugPrint("Server Error: Failed to get Asset Category Data")
                    self.dismiss(self)
                    return
                    }
                }
            }
        }
        apiQueue.addOperation(downloadOperation)
    }
    
    func updateSelection(selection:String){
        if(comboAssetCategory.stringValue==""){
            comboAssetName.isEnabled = false
        } else{
            getAssets(category: selection)
        }
    }
    
    func getAssets(category: String){
        let downloadOperation = BlockOperation{
            //When All operations complete, call success case.
        }
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        self.manager = Alamofire.Session(configuration:configuration)
        let headers:HTTPHeaders = [
            "token": requestToken]
        
        let parameters: Parameters = [
            "category":category
        ]

        let requestURL = host + ":" + port + "/assets/"
        downloadOperation.addExecutionBlock {
            self.manager.request(requestURL, method: .get, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result {
            case .failure( _):
                return
            case .success(let value):
                let jsonData = JSON(value)
                print(jsonData)
                if jsonData["response-code"]==200 {
                    if jsonData["assets"].array != nil{
                        if let eventTypes:[String] = jsonData["assets"].arrayValue.map({ $0.stringValue}){
                            DispatchQueue.main.async {
                                self.comboAssetName.addItems(withObjectValues: eventTypes)
                                self.comboAssetName.selectItem(at: 1)
                                self.comboAssetName.isEnabled = true
                            }
                        }
                    } else{
                        self.comboAssetName.addItem(withObjectValue: "No Assets In Database!")
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
    
    /**
        Handles when the selection of a comboBox changes.
     */
    func comboBoxSelectionDidChange(_ notification: Notification) {
        updateSelection(selection: comboAssetCategory.stringValue)
    }
}
