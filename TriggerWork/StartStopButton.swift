//
//  StartStopButton.swift
//  TriggerWork
//
//  Created by Phil Henson on 5/7/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation
import UIKit

class StartStopButton: UIButton {
  
  override var isSelected: Bool {
    willSet(newValue) {
      
      if newValue {
        self.clipsToBounds = false
        self.pumpAnimation()
      } else {
        self.clipsToBounds = true
        self.pumpAnimation()
      }
    }
    didSet {
      
    }
  }
  
  //MARK: Initializers
  override init(frame : CGRect) {
    super.init(frame : frame)
    setup()
  }
  
  convenience init() {
    self.init(frame:CGRect.zero)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    setup()
  }
  
  func setup() {
    
    self.layoutIfNeeded()
    self.layer.cornerRadius = self.frame.width/2;
    self.clipsToBounds = true
    self.tintColor = UIColor.white

    self.setTitle("Start", for: .normal)
    self.setTitle("Stop", for: .selected)
    self.setTitleColor(UIColor.white, for: .normal)
    self.setTitleColor(UIColor.white, for: .selected)

    // Discoverd the proper way to set a background color, instead of manually changing on 'setSelected'
    self.backgroundColor = UIColor.clear
    self.setBackgroundImage(UIImage.imageWithColor(color: Colors.defaultGreenColor()), for: .normal)
    self.setBackgroundImage(UIImage.imageWithColor(color: Colors.defaultRedColor()), for: .selected)
  }
}
