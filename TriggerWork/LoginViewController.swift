//
//  LoginViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreData
import SVProgressHUD
import ReachabilitySwift

class LoginViewController: UIViewController {
  
  var ref: FIRDatabaseReference!
  let moc = DataController().managedObjectContext
  var accessToken: String?
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize database reference
    ref = FIRDatabase.database().reference()
    
    // Fetch access token from previous session, if available
    fetchAccessToken()
    
    // Initialize SVProgressHUD style
    SVProgressHUD.setDefaultStyle(.Dark)
    SVProgressHUD.setDefaultMaskType(.Black)
  }
  
  func fetchAccessToken() {
    let authFetch = NSFetchRequest(entityName: "Authentication")
    
    do {
      let fetchedAuth = try moc.executeFetchRequest(authFetch) as! [Authentication]
      guard let authentication = fetchedAuth.first else { return }
      guard let token = authentication.accessToken else { return }
      accessToken = token
    } catch {
      fatalError("Failure to fetch entity: \(error)")
    }
  }
  
  @IBAction func skipButtonPressed(sender: AnyObject) {
    // Sign in user anonymously to obtain temp user ID
    self.loginAnonymousUser()
  }
  
  @IBAction func loginButtonPressed(sender: AnyObject) {
    
    // 1. Check network availability
    let reachability: Reachability
    do {
      reachability = try Reachability.reachabilityForInternetConnection()
    } catch {
      print("Unable to create Reachability")
      return
    }
    
    // 2. Check if user is already signed in
    FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
      if user != nil {
        print("User already signed in.")
        self.performSegueWithIdentifier("LoginSegue", sender: self)
      } else {
        // Check for existing access token
        if self.accessToken != nil {
          print("Access token exists - logging in...")
          if reachability.isReachable() {
            self.loginAuthorizedUserWithAccessToken(self.accessToken!)
          } else {
            // No network connection
            let alertPresenter = AlertPresenter(controller: self)
            alertPresenter.presentNoNetworkForLoginError()
          }
        } else {
          // Create new access token
          if reachability.isReachable() {
            // Network connection via WiFi or Cellular
            print("Access token does not exist - trying Facebook login")
            self.beginFacebookLoginProcedure()
            
          } else {
            // No network connection
            let alertPresenter = AlertPresenter(controller: self)
            alertPresenter.presentNoNetworkForLoginError()
          }
        }
      }
    }
  }
  
  // MARK - Login Helper Methods
  
  
  // Facebook Login
  func beginFacebookLoginProcedure() {
    let login = FBSDKLoginManager()
    login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result, error) in
      if let error = error {
        print("Login error: \(error.localizedDescription)")
        return
      } else if (result.isCancelled) {
        print("Login cancelled")
      } else {
        print("Login successful")
        dispatch_async(dispatch_get_main_queue()) {
          SVProgressHUD.show()
        }
        
        // Save access token to prevent facebok dialog from reappearing after initial authorization
        // Also helps in offline mode to maintain authenticated user's access token
        let entity = NSEntityDescription.insertNewObjectForEntityForName("Authentication", inManagedObjectContext: self.moc) as! Authentication
        
        entity.setValue(FBSDKAccessToken.currentAccessToken().tokenString, forKey: "accessToken")
        
        print("Saving access token...")
        do {
          try self.moc.save()
        } catch {
          fatalError("Failure to save context: \(error)")
        }
        
        // User is authorized, now log in
        self.loginAuthorizedUserWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
      }
    }
  }
  
  // Authorized User Login - Facebook
  func loginAuthorizedUserWithAccessToken(accessToken: String) {
    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
    FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
      dispatch_async(dispatch_get_main_queue()) {
        SVProgressHUD.dismiss()
      }
      if let error = error {
        print("Firebase sign-in error: \(error.localizedDescription)")
        return
      } else {
        // Link anonymous user with authorized account
        if let user = user {
          user.linkWithCredential(credential) { (user, error) in
            if let error = error {
              print("Error linking accounts: \(error.localizedDescription)")
              print("Logging in anyway...")
              self.performSegueWithIdentifier("LoginSegue", sender: self)
            } else {
              self.performSegueWithIdentifier("LoginSegue", sender: self)
            }
            
          }
        }
      }
    })
  }
  
  // Anonymous User Login
  func loginAnonymousUser() {
    FIRAuth.auth()?.signInAnonymouslyWithCompletion() { (user, error) in
      dispatch_async(dispatch_get_main_queue()) {
        SVProgressHUD.dismiss()
      }
      if let error = error {
        print("Firebase sign-in error: \(error.localizedDescription)")
        return
      } else {
        self.performSegueWithIdentifier("LoginSegue", sender: self)
      }
    }
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