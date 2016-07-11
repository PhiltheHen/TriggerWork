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
  func setBorderColorFromUIColor(color: UIColor) {
    self.borderColor = color.CGColor
  }
}

extension Double {
  /**
   Simple rounding function for doubles.
   */
  func roundToHundredths() -> Double {
    return Double(round(100*self)/100)
  }
}

extension UIView {
  /**
   Simple pump animation for a UIView
   */
  func pumpAnimation() {
    UIView.animateWithDuration(0.3/1.5, animations: { 
      self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)
      }) { _ in
        UIView.animateWithDuration(0.3/2, animations: { 
          self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)
          }, completion: { _ in
            UIView.animateWithDuration(0.3/2, animations: { 
              self.transform = CGAffineTransformIdentity
            })
        })
    }
  }
}

extension UIButton {
  func enable() {
    self.alpha = 1.0
    self.enabled = true
  }
  
  func disable() {
    self.alpha = 0.5
    self.enabled = false
  }
}

extension NSDate {
  /**
   Returns a string from date in the format "dd-MM-yyyy HH:mm:ss"
   */
  class func currentDateToString() -> (String){
    let formatter = NSDateFormatter()
    formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    let stringDate: String = formatter.stringFromDate(NSDate())
    return stringDate
  }
  
  /**
   Returns a date from string preferably in the format "dd-MM-yyyy HH:mm:ss"
   */
  class func stringToDate(dateString:String) -> (NSDate) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    return dateFormatter.dateFromString(dateString)!
  }
  
  /**
   Formats a string of seconds into HH:mm:ss.0
   Source: http://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
   */
  class func formatElapsedSecondsDouble(elapsedSeconds: Double) -> String {
    let hours = Int(elapsedSeconds / 3600)
    let minutes = Int((elapsedSeconds % 3600) / 60)
    let seconds: Double = (elapsedSeconds % 3600) % 60
    
    if hours > 0 {
      return "\(hours):\(minutes):\(seconds)"
    } else if minutes > 0 {
      return "\(minutes):\(seconds)"
    }
    
    return "\(seconds)"
    
  }
}