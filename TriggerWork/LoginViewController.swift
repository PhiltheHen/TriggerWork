//
//  LoginViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Craftsbury Outdoor Center. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
    // MARK: Constants
    let ref = Firebase(url: firebaseURL)

    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: UI Settings
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
