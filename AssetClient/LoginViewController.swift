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

    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var host: NSTextField!
    let auth = Authentication()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func LoginClicked(_ sender: Any) {
        if password.stringValue.isEmpty || username.stringValue.isEmpty || host.stringValue.isEmpty {
            print("one of these fields is empty!")
        }
    }
    


}

