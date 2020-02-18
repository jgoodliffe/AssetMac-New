//
//  PasswordChangeViewController.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 18/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa

class PasswordChangeViewController: NSViewController {
    @IBOutlet weak var btnChangePassword: NSLayoutConstraint!
    @IBOutlet weak var btnDismiss: NSButton!
    @IBOutlet weak var txtCurrentPass: NSSecureTextField!
    @IBOutlet weak var txtNewPass: NSSecureTextField!
    @IBOutlet weak var txtVerifyPass: NSSecureTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var labelStatus: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.isHidden = true
        // Do view setup here.
    }
    @IBAction func btnDismissClicked(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func btnChangePasswordClicked(_ sender: Any) {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)
    }
    
    
}
