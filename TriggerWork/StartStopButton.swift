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
        self.backgroundColor = Colors.defaultRedColor()
        self.pumpAnimation()
      } else {
        self.backgroundColor = Colors.defaultGreenColor()
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
    self.layer.cornerRadius = self.frame.width/2;
    self.backgroundColor = Colors.defaultGreenColor()
    self.tintColor = UIColor.white

    self.setTitle("Start", for: UIControlState())
    self.setTitle("Stop", for: .selected)
    self.setBackgroundImage(nil, for: .selected)
    self.setTitleColor(UIColor.white, for: UIControlState())
    self.setTitleColor(UIColor.white, for: .selected)
  }
  
}
