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
  
  override var selected: Bool {
    willSet(newValue) {
      print("will set")

      if newValue {
        self.backgroundColor = Colors.defaultRedColor()
        self.pumpAnimation()
      } else {
        self.backgroundColor = Colors.defaultGreenColor()
        self.pumpAnimation()
      }
    }
    didSet {
      print("did set")

    }
  }
  
  //MARK: Initializers
  override init(frame : CGRect) {
    super.init(frame : frame)
    setup()
  }
  
  convenience init() {
    self.init(frame:CGRectZero)
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
    self.tintColor = UIColor.whiteColor()

    self.setTitle("Start", forState: .Normal)
    self.setTitle("Stop", forState: .Selected)
    self.setBackgroundImage(nil, forState: .Selected)
    self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    self.setTitleColor(UIColor.blackColor(), forState: .Selected)
  }
  
}