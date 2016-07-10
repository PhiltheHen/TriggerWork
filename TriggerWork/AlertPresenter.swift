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
  
  init(controller: UIViewController) {
    viewController = controller;
  }
  
  func presentAlertWithTitle(title: String,
                             message: String,
                             okHandler: ((UIAlertAction) -> Void)?) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: okHandler)
    alertController.addAction(okAction)
    viewController?.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func presentAlertWithTitle(title: String,
                             message: String,
                             okHandler: ((UIAlertAction) -> Void)?,
                             cancelHandler: ((UIAlertAction) -> Void)?) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: okHandler)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelHandler)
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    viewController?.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func presentNoNetworkForLoginError() {
    self.presentAlertWithTitle("Network unavailable",
                                         message: "Can't authorize login without network connection.") { (_) in
    }

  }
}