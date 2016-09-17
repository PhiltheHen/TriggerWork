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
  var isSignedOut = false
  var authListener: FIRAuthStateDidChangeListenerHandle?
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize database reference
    ref = FIRDatabase.database().reference()
    
    // Fetch access token from previous session, if available
    fetchAccessToken()
    
    // Initialize SVProgressHUD style
    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.setDefaultMaskType(.black)
  }
  
  func fetchAccessToken() {
    let authFetch = NSFetchRequest(entityName: "Authentication")
    
    do {
      let fetchedAuth = try moc.fetch(authFetch) as! [Authentication]
      guard let authentication = fetchedAuth.first else { return }
      guard let token = authentication.accessToken else { return }
      accessToken = token
    } catch {
      fatalError("Failure to fetch entity: \(error)")
    }
  }
  
  @IBAction func skipButtonPressed(_ sender: AnyObject) {
    // Sign in user anonymously to obtain temp user ID
    self.loginAnonymousUser()
  }
  
  @IBAction func loginButtonPressed(_ sender: AnyObject) {
    
    isSignedOut = false
    
    // 1. Check network availability
    let reachability: Reachability
    do {
      reachability = try Reachability.reachabilityForInternetConnection()
    } catch {
      print("Unable to create Reachability")
      return
    }
    
    // 2. Check if user is already signed in
    authListener = FIRAuth.auth()?.addStateDidChangeListener { auth, user in
      
      if self.isSignedOut { return }
      
      DispatchQueue.main.async {
        SVProgressHUD.show()
      }
      
      if user != nil {
        print("User already signed in.")
        self.removeAuthStateListener()
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
      } else {
        // Check for existing access token
        if self.accessToken != nil {
          print("Access token exists - logging in...")
          if reachability.isReachable() {
            self.removeAuthStateListener()
            self.loginAuthorizedUserWithAccessToken(self.accessToken!)
          } else {
            // No network connection
            let alertPresenter = AlertPresenter(controller: self)
            alertPresenter.presentNoNetworkForLoginError()
            DispatchQueue.main.async {
              SVProgressHUD.dismiss()
            }
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
            DispatchQueue.main.async {
              SVProgressHUD.dismiss()
            }
          }
        }
      }
    }
  }
  
  // MARK - Login Helper Methods
  
  
  // Facebook Login
  func beginFacebookLoginProcedure() {
    let login = FBSDKLoginManager()
    login.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
      if let error = error {
        print("Login error: \(error.localizedDescription)")
        return
      } else if (result?.isCancelled)! {
        print("Login cancelled")
      } else {
        print("Login successful")
        
        // Save access token to prevent facebok dialog from reappearing after initial authorization
        // Also helps in offline mode to maintain authenticated user's access token
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Authentication", into: self.moc) as! Authentication
        
        entity.setValue(FBSDKAccessToken.current().tokenString, forKey: "accessToken")
        
        print("Saving access token...")
        do {
          try self.moc.save()
        } catch {
          fatalError("Failure to save context: \(error)")
        }
        
        // User is authorized, now log in
        self.loginAuthorizedUserWithAccessToken(FBSDKAccessToken.current().tokenString)
      }
    }
  }
  
  // Authorized User Login - Facebook
  func loginAuthorizedUserWithAccessToken(_ accessToken: String) {
    let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken)
    FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      if let error = error {
        print("Firebase sign-in error: \(error.localizedDescription)")
        return
      } else {
        // Link anonymous user with authorized account
        if let user = user {
          user.link(with: credential) { (user, error) in
            if let error = error {
              print("Error linking accounts: \(error.localizedDescription)")
              print("Logging in anyway...")
              self.performSegue(withIdentifier: "LoginSegue", sender: self)
            } else {
              self.performSegue(withIdentifier: "LoginSegue", sender: self)
            }
            
          }
        }
      }
    })
  }
  
  // Anonymous User Login
  func loginAnonymousUser() {
    FIRAuth.auth()?.signInAnonymously() { (user, error) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      if let error = error {
        print("Firebase sign-in error: \(error.localizedDescription)")
        return
      } else {
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
      }
    }
  }
  
  // MARK: UI Settings
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: Unwind Segues
  @IBAction func logoutUser(_ segue:UIStoryboardSegue) {
    isSignedOut = true
    //FBSDKLoginManager().logOut()
    try! FIRAuth.auth()!.signOut()
  }
  
  // MARK: Navigation
  func removeAuthStateListener() {
    FIRAuth.auth()?.removeStateDidChangeListener(authListener!)
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    passwordTextField.resignFirstResponder()
    return true
  }
}
