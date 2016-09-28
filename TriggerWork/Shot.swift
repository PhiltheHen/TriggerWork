//
//  Shot.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/19/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation

class Shot {
  var shotTime: String
  var data: [String: [String:String]]
  var interrupts: [String: Bool]
  
  init(shotTime: String, data:[String: [String:String]], interrupts:[String : Bool]) {
    self.shotTime = shotTime
    self.data = data
    self.interrupts = interrupts
  }
}
