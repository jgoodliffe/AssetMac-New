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
    @IBOutlet weak var btnReset: NSButton!
    let auth = Authentication()
    var loggingIn = false
    var resettingPassword = false
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
        login()
    }
    @IBAction func enterPressed(_ sender: Any) {
        login()
    }
    @IBAction func resetPasswordPressed(_ sender: Any) {
        resetPassword()
    }
    
    func resetPassword(){
        if resettingPassword{
            resettingPassword = false
            btnReset.title = "Reset Password"
            self.progressIndicator.isHidden = true
            self.progressIndicator.stopAnimation(self)
            loginQueue.cancelAllOperations()
            labelError.textColor = NSColor.red
            return
        }
        resettingPassword = true
        labelError.isHidden = true
        
        //Check for Null username.
        if username.stringValue.isEmpty || host.stringValue.isEmpty{
            labelError.isHidden = false
        } else{
            if(!host.stringValue.contains("http://")){
                host.stringValue = "http://" + host.stringValue
            }
            if(validateURLFormat(inputURL: host.stringValue)){
                progressIndicator.isHidden = false
                progressIndicator.startAnimation(self)
                
                let hostName = host.stringValue
                let uName = username.stringValue
                btnReset.title = "Abort"
                
                //Attempt to Reset Password
                if loginQueue.operationCount<1{
                    loginQueue.addOperation {
                        self.auth.resetPassword(hostName: hostName, username: uName, success: {(response)-> Void in
                            if response{
                                debugPrint("Password reset complete.")
                                DispatchQueue.main.async { [weak self] in
                                    self?.progressIndicator.stopAnimation(self)
                                    self?.progressIndicator.isHidden = true
                                    self?.labelError.stringValue = "Successfully reset password. \n Please check your email for the new password."
                                    self?.labelError.isHidden = false
                                    self?.labelError.textColor = NSColor.green
                                    self?.btnReset.title = "Reset Password"
                                    self?.resettingPassword = false
                                    
                                }
                            }
                        }, failure: {(error)-> Void in
                            DispatchQueue.main.async { [weak self] in
                                self?.progressIndicator.stopAnimation(self)
                                self?.progressIndicator.isHidden = true
                                self?.labelError.isHidden = false
                                self?.labelError.stringValue = error
                                self?.btnReset.title = "Reset Password"
                                self?.resettingPassword = false;
                            }
                        })
                    }
                }
                
            }
        }
    }
    
    func login(){
        if loggingIn{
            loggingIn = false
            btnLogin.title = "Log In"
            self.progressIndicator.isHidden = true;
            self.progressIndicator.stopAnimation(self)
            labelError.textColor = NSColor.red
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
                                debugPrint("Login completed.")
                                ///Update UI in Main thread...
                                DispatchQueue.main.async { [weak self] in
                                    self?.progressIndicator.stopAnimation(self)
                                    self?.progressIndicator.isHidden = true
                                    self?.btnLogin.title = "Log In"
                                    self?.loggingIn = false;
                                    self?.performSegue(withIdentifier: "transtionToDashboard", sender: nil)
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

