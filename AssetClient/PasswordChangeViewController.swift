//
//  PasswordChangeViewController.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 18/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit
import Alamofire
import SwiftyJSON

extension Notification.Name {
    static let changedUserPassword = Notification.Name("changedUserPassword")
    static let hideDashboard = Notification.Name("hideDashboard")
    static let showDashboard = Notification.Name("showDashboard")
}

class PasswordChangeViewController: NSViewController {
    @IBOutlet weak var btnChangePassword: NSButtonCell!
    @IBOutlet weak var btnDismiss: NSButton!
    @IBOutlet weak var txtCurrentPass: NSSecureTextField!
    @IBOutlet weak var txtNewPass: NSSecureTextField!
    @IBOutlet weak var txtVerifyPass: NSSecureTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var labelStatus: NSTextField!
    
    var changingPassword = false
    
    //Token Stores + App Delegate Declaration
    let appDelegate = NSApp.delegate as? AppDelegate
    let coreDataFuncs = CoreDataFuncs()
    var authenticationInfo:[String] = []
    
    
    //Alamofire Information
    let port: String = ":8080"

    var manager = Alamofire.Session.default
    let configuration = URLSessionConfiguration.default
    
    lazy var changePasswordInProgress: [IndexPath: Operation] = [:]
    lazy var changePasswordQueue: OperationQueue = {
      var changePasswordQueue = OperationQueue()
      changePasswordQueue.name = "Change Password queue"
      changePasswordQueue.maxConcurrentOperationCount = 1
      return changePasswordQueue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.isHidden = true
        authenticationInfo = coreDataFuncs.retrieveTokenAndHost()
        NotificationCenter.default.post(Notification(name: .hideDashboard))
    }
    
    @IBAction func btnDismissClicked(_ sender: Any) {
        changingPassword = false
        changePasswordQueue.cancelAllOperations()
        NotificationCenter.default.post(Notification(name: .showDashboard))
        self.dismiss(self)
    }
    
    @IBAction func btnChangePasswordClicked(_ sender: Any) {
        let answer = dialogConfirm(question: "This action will log you out!", text: "Changing your password is an irreversible action that will require you to log in again.")
        if(answer){
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(self)
            changePassword()
        } else{
            NotificationCenter.default.post(Notification(name: .showDashboard))
            dismiss(self)
        }
    }
    
    func validateFields()->Bool{
        let currentPassword = txtCurrentPass.stringValue
        let newPassword = txtNewPass.stringValue
        let verifyPassword = txtVerifyPass.stringValue
        
        //Check if anything has actually been entered
        if(currentPassword==""||newPassword==""||verifyPassword==""){
            labelStatus.textColor = NSColor.red
            labelStatus.stringValue = "You have not filled in all fields.\nPlease check your entry and try again."
            return false
        }
        
        //Check if new password meets length requirements
        if(newPassword.count<8 || newPassword.count>80){
            labelStatus.textColor = NSColor.red
            labelStatus.stringValue = "Your new password is too short.\nPlease check your entry and try again."
            return false
        }
        
        //Check if password contains numbers and letters
        let textRange = newPassword.rangeOfCharacter(from: CharacterSet.letters)
        let decimalRange = newPassword.rangeOfCharacter(from: CharacterSet.decimalDigits)
        if(decimalRange==nil || textRange==nil){
            labelStatus.textColor = NSColor.red
            labelStatus.stringValue = "Your new password must contain both letters and numbers.\nPlease check your entry and try again."
            return false
        }
        
        //Check if password contains forbidden characters
        if(newPassword.contains("/") || newPassword.contains("\"")){
            labelStatus.textColor = NSColor.red
            labelStatus.stringValue = "Your password may not contain slashes.\nPlease check your entry and try again."
            return false
        }
        
        //Check if new password and verify password are the same.
        let isEqual = (newPassword == verifyPassword)
        if(!isEqual){
            labelStatus.textColor = NSColor.red
            labelStatus.stringValue = "Your new password doesn't match the verified password.\nPlease check your entry and try again."
            return false
        }
        return true
    }
    
    func dialogConfirm(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    @IBAction func enterKeypressed(_ sender: Any) {
        let answer = dialogConfirm(question: "This action will log you out!", text: "Changing your password is an irreversible action that will require you to log in again.")
        if(answer){
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(self)
            changePassword()
        } else{
            dismiss(self)
        }
    }
    
    func changePassword(){
        if changingPassword{
            changingPassword = false
            btnChangePassword.title = "Change Password"
            labelStatus.stringValue = "Enter your existing password, followed by your desired password."
            progressIndicator.isHidden = true
            progressIndicator.stopAnimation(self)
            labelStatus.textColor = NSColor.systemGray
            changePasswordQueue.cancelAllOperations()
        }
        
        changingPassword = true
        labelStatus.textColor = NSColor.systemGray
        labelStatus.stringValue = "Changing password..."
        btnChangePassword.title = "Abort"
        
        if(validateFields()){
            configuration.timeoutIntervalForRequest = 5
            configuration.timeoutIntervalForResource = 5
            
            self.manager = Alamofire.Session(configuration:configuration)
            
            let currentPassEncoded = ((txtCurrentPass.stringValue).data(using: .utf8))?.base64EncodedString() ?? "" //Encode to UTF-8 -> Unwrap Optional
            let newPassEncoded = ((txtNewPass.stringValue).data(using: .utf8))?.base64EncodedString() ?? "" //Encode to UTF-8 -> Unwrap Optional
            
            let headers:HTTPHeaders = [
                "token": authenticationInfo.first ?? "",
                "currentPassword": currentPassEncoded,
                "newPassword": newPassEncoded
            ]
            
            let requestURL = authenticationInfo[1] + port   + "/utilities/changePassword"
            
            if changePasswordQueue.operationCount<1{
                changePasswordQueue.addOperation {
                    self.manager.request(requestURL, method: .post, headers: headers).responseJSON{ response in
                        switch response.result{
                        case.success(let jsonResponse):
                            if let JSON = jsonResponse as? [String:Any]{
                                let status = JSON["response-code"] as! Int
                                if(status==200){
                                    DispatchQueue.main.async {
                                        self.btnChangePassword.title = "Change Password"
                                        self.progressIndicator.stopAnimation(self)
                                        self.progressIndicator.isHidden = true
                                        self.labelStatus.textColor = NSColor.green
                                        self.labelStatus.stringValue = "Successfully changed password."
                                        
                                        //Close window after a second pause.
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            self.dismiss(self)
                                            
                                            //Notify Dashboard Window(s) to close...
                                            NotificationCenter.default.post(Notification(name: .changedUserPassword))
                                            self.performSegue(withIdentifier: "backToLogin", sender: nil)
                                        }
                                    }
                                } else{
                                    let errorMessage:String = "Error Changing Password.\n Error Code: "+String(status)+" "+String(JSON["error-type"] as! String)
                                    DispatchQueue.main.async {
                                        self.labelStatus.textColor = NSColor.red
                                        self.labelStatus.stringValue = errorMessage
                                        self.btnChangePassword.title = "Change Password"
                                        self.progressIndicator.stopAnimation(self)
                                        self.progressIndicator.isHidden = true
                                    }
                                }
                            }
                        case .failure(let error):
                            let errorString = String(describing: error.localizedDescription)
                            DispatchQueue.main.async {
                                self.labelStatus.textColor = NSColor.red
                                self.labelStatus.stringValue = "There was an error changing the password: \n" + errorString
                                self.btnChangePassword.title = "Change Password"
                                self.progressIndicator.stopAnimation(self)
                                self.progressIndicator.isHidden = true
                            }
                        }
                    }
                }
            }
        } else{
            btnChangePassword.title = "Change Password"
            changingPassword = false
            progressIndicator.isHidden = true
            progressIndicator.stopAnimation(self)
        }
    }
}
