//
//  AlertPresenter.swift
//  TriggerWork
//
//  Created by Phil Henson on 5/7/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation
import UIKit

class AlertPresenter: NSObject {
  
  var viewController: UIViewController?
  var inputTextField: UITextField?
  
  init(controller: UIViewController) {
    viewController = controller;
  }
  
  func presentAlertWithTitle(_ title: String,
                             message: String,
                             okHandler: ((UIAlertAction) -> Void)?) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: okHandler)
    alertController.addAction(okAction)
    viewController?.present(alertController, animated: true, completion: nil)
  }
  
  func presentTextFieldAlertWithTitle(_ title: String,
                                      message: String,
                                      placeholderText: String?,
                                      cancelHandler: ((UIAlertAction) -> Void)?,
                                      saveHandler: ((UIAlertAction) -> Void)?) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
    let saveAction = UIAlertAction(title: "Save", style: .default, handler: saveHandler)
    
    alertController.addAction(cancelAction)
    alertController.addAction(saveAction)

    
    alertController.addTextField { (textField) in
      textField.placeholder = placeholderText
      self.inputTextField = textField
    }
    
    viewController?.present(alertController, animated: true, completion: nil)
  }
  
  
  
  func presentAlertWithTitle(_ title: String,
                             message: String,
                             okHandler: ((UIAlertAction) -> Void)?,
                             cancelHandler: ((UIAlertAction) -> Void)?) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: okHandler)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    viewController?.present(alertController, animated: true, completion: nil)
  }
  
  func presentNoNetworkForLoginError() {
    self.presentAlertWithTitle("Network unavailable",
                               message: "Can't authorize login without network connection.") { (_) in
    }
    
  }
}
