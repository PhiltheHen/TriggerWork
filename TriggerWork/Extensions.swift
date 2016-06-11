//
//  Extensions.swift
//  TriggerWork
//
//  Created by Phil Henson on 4/30/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
  func setBorderColorFromUIColor(color: UIColor) {
    self.borderColor = color.CGColor
  }
}

extension UIView {
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