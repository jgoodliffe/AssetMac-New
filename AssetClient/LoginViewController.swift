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

class LoginViewController: NSViewController {

    //Always make sure IBOutlet Connections are valid!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var host: NSTextField!
    @IBOutlet weak var labelError: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    let auth = Authentication()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelError.isHidden = true
        progressIndicator.isHidden = true
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func validateURLFormat(inputURL: String)-> Bool{
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: inputURL, options: [], range: NSRange(location: 0, length: inputURL.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == inputURL.utf16.count
        } else {
            return false
        }
    }
    
    @IBAction func LoginClicked(_ sender: Any) {
        //debugPrint("Click triggered!")
        //Check for Null values.
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
                //Attempt Login - DispatchQueue
                
                let hostName = host.stringValue
                let uName = username.stringValue
                let pword = passwordField.stringValue
                //Execute CompletionHandler task in background..
                DispatchQueue.global(qos: .userInitiated).async {
                    [weak self] in
                    guard let self = self else{
                        return
                    }
                    self.auth.login(hostName: hostName,username: uName, password: pword, completion: { (success) -> Void in
                        // When download completes,control flow goes here.
                        if success {
                            print("Success!")
                            //Update UI in Main thread...
                            DispatchQueue.main.async { [weak self] in
                                self?.progressIndicator.stopAnimation(self)
                                self?.progressIndicator.isHidden = true
                            }
                            //Trigger Seague..
                        } else {
                            print("No Success!")
                            DispatchQueue.main.async { [weak self] in
                                self?.progressIndicator.stopAnimation(self)
                                self?.progressIndicator.isHidden = true
                            }
                        }
                    })
                }

            
                //auth.login(host: host.stringValue, username: username.stringValue, password: passwordField.stringValue)
            } else{
                labelError.isHidden = false;
            }
        }
    }
    


}

