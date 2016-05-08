//
//  RoundedButton.swift
//  TriggerWork
//
//  Created by Phil Henson on 5/7/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedButton: UIButton {
  
  @IBInspectable var cornerRadius: CGFloat = 0.0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 0.0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
    didSet {
      layer.borderColor = borderColor.CGColor
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}