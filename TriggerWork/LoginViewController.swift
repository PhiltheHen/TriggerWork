//
//  LoginViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
  
  // MARK: Constants
  let ref = Firebase(url: firebaseURL)
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize SVProgressHUD style
    SVProgressHUD.setDefaultStyle(.Dark)
    SVProgressHUD.setDefaultMaskType(.Black)
  }
  
  // MARK: UI Settings
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    passwordTextField.resignFirstResponder()
    return true
  }
}