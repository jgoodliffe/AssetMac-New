//
//  ViewController.swift
//  AssetClient
//
//  Created by Jamie Goodliffe on 04/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import AppKit

class LoginViewController: NSViewController {

    ///Always make sure IBOutlet Connections are valid!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var host: NSTextField!
    @IBOutlet weak var labelError: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var btnLogin: NSButton!
    let auth = Authentication()
    var loggingIn = false
    lazy var loginInProgress: [IndexPath: Operation] = [:]
    lazy var loginQueue: OperationQueue = {
      var loginQueue = OperationQueue()
      loginQueue.name = "Download queue"
      loginQueue.maxConcurrentOperationCount = 1
      return loginQueue
    }()
    
    let appDelegate = NSApp.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelError.isHidden = true
        btnLogin.title = "Log In"
        progressIndicator.isHidden = true
        
        /// Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        /// Update the view, if already loaded.
        }
    }
    
    func validateURLFormat(inputURL: String)-> Bool{
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: inputURL, options: [], range: NSRange(location: 0, length: inputURL.utf16.count)) {
            /// it is a link, if the match covers the whole string
            return match.range.length == inputURL.utf16.count
        } else {
            return false
        }
    }
    
    @IBAction func LoginClicked(_ sender: Any) {
        
        if loggingIn{
            loggingIn = false
            btnLogin.title = "Log In"
            self.progressIndicator.isHidden = true;
            self.progressIndicator.stopAnimation(self)
            loginQueue.cancelAllOperations() ///Cancel login.
            return;
        }
        loggingIn = true
        ///Check for Null values.
        labelError.isHidden = true
        if passwordField.stringValue.isEmpty || username.stringValue.isEmpty || host.stringValue.isEmpty {
            labelError.isHidden = false
        } else{
            if(!host.stringValue.contains("http://")){
                host.stringValue = "http://" + host.stringValue
            }
            if(validateURLFormat(inputURL: host.stringValue)){
                progressIndicator.isHidden = false
                progressIndicator.startAnimation(self)
                debugPrint("Attempting login -  Host: "+host.stringValue+" Username: "+username.stringValue+" Password: "+passwordField.stringValue)
                
                ;
                ///Attempt Login - DispatchQueue
                
                let hostName = host.stringValue
                let uName = username.stringValue
                let pword = passwordField.stringValue
                btnLogin.title = "Abort"
                
                ///Check if another operation is already running before we attempt to start another.
                if loginQueue.operationCount<1{
                        loginQueue.addOperation{
                        self.auth.login(hostName: hostName, username: uName, password: pword, success: { (response) -> Void in
                            // When download completes,control flow goes here.
                            if response {
                                print("Success!")
                                ///Update UI in Main thread...
                                DispatchQueue.main.async { [weak self] in
                                    self?.progressIndicator.stopAnimation(self)
                                    self?.progressIndicator.isHidden = true
                                    self?.btnLogin.title = "Log In"
                                    self?.loggingIn = false;
                                    
                                    /* - Printing out Received token.
                                    let context = self?.appDelegate?.persistentContainer.viewContext
                                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AuthStore")
                                    var token:String = "nil"
                                    do{
                                        let tokenObject = try context?.fetch(fetchRequest)
                                        for entry in tokenObject as! [NSManagedObject]{
                                            token = entry.value(forKey: "token") as! String
                                        }
                                    } catch{
                                        print("Failed to retrieve key")
                                    }
                                    
                                    let alert = NSAlert()
                                    alert.messageText = "Successful login. Token: " + token
                                    alert.runModal()
                                    */
                                }
                                ///Trigger Seague..
                            }
                        }, failure: { (error) -> Void in
                            DispatchQueue.main.async { [weak self] in
                                self?.progressIndicator.stopAnimation(self)
                                self?.progressIndicator.isHidden = true
                                self?.labelError.isHidden = false
                                self?.labelError.stringValue = error
                                self?.btnLogin.title = "Log In"
                                self?.loggingIn = false;
                            }
                        })
                    }
                }
                //auth.login(host: host.stringValue, username: username.stringValue, password: passwordField.stringValue)
            } else{
                labelError.isHidden = false;
            }
        }
    }
    


}

