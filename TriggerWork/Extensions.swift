//
//  Extensions.swift
//  TriggerWork
//
//  Created by Phil Henson on 4/30/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation
import UIKit

/**
 Converts UIColor to CGColor
 */
extension CALayer {
  func setBorderColorFromUIColor(_ color: UIColor) {
    self.borderColor = color.cgColor
  }
}

extension Double {
  /**
   Simple rounding function for doubles.
   */
  func roundToHundredths() -> Double {
    return Double((100*self).rounded()/100)
  }
}

extension UIView {
  /**
   Simple pump animation for a UIView
   */
  func pumpAnimation() {
    UIView.animate(withDuration: 0.3/1.5, animations: { 
      self.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
      }, completion: { _ in
        UIView.animate(withDuration: 0.3/2, animations: { 
          self.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
          }, completion: { _ in
            UIView.animate(withDuration: 0.3/2, animations: { 
              self.transform = CGAffineTransform.identity
            })
        })
    }) 
  }
}

extension Array {
  func indexExists(_ index: Int) -> Bool {
    return self.indices.contains(index)
  }
}

extension UIButton {
  func enable() {
    self.alpha = 1.0
    self.isEnabled = true
  }
  
  func disable() {
    self.alpha = 0.5
    self.isEnabled = false
  }
}

extension UserDefaults {
  class func savePeripheralName(_ uuid: String, name: String) {
    standard.set(name, forKey: uuid)
  }
  
  class func retrievePeripheralName(_ uuid: String) -> String? {
    return standard.object(forKey: uuid) as! String?
  }
}

extension UIImage {
  
  class func imageWithColor(color:UIColor?) -> UIImage! {
    
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    
    let context = UIGraphicsGetCurrentContext();
    
    if let color = color {
      
      color.setFill()
    }
    else {
      
      UIColor.white.setFill()
    }
    
    context!.fill(rect);
    
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
  }
}

extension Date {
  /**
   Returns a string from date in the format "dd-MM-yyyy HH:mm:ss"
   */
  static func currentDateToString() -> (String){
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    let stringDate: String = formatter.string(from: Date())
    return stringDate
  }
  
  /**
   Returns a date from string preferably in the format "dd-MM-yyyy HH:mm:ss"
   */
  static func stringToDate(_ dateString:String) -> (Date) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    return dateFormatter.date(from: dateString)!
  }

  static func formatElapsedSecondsDouble(_ elapsedSeconds: Double) -> String {
    let hours = Int(elapsedSeconds / 3600)
    let minutes = Int((elapsedSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
    var seconds: Double = elapsedSeconds.truncatingRemainder(dividingBy: 60)
    seconds = seconds.roundToHundredths()
    
    if hours > 0 {
      return "\(hours):\(minutes):\(seconds)"
    } else if minutes > 0 {
      return "\(minutes):\(seconds)"
    }
    
    return "\(seconds)"
    
  }
}
