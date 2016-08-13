//
//  RepeatingTimer.swift
//  TriggerWork
//
//  Created by Phil Henson on 8/12/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation

class RepeatingTimer: NSObject {
  private var timer: NSTimer?
  private var callback: (Void -> Void)?
  
  init(_ delaySeconds: Double, _ callback: Void -> Void) {
    super.init()
    self.callback = callback
    self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(delaySeconds),
                                                        target: self,
                                                        selector: #selector(Timeout.invoke),
                                                        userInfo: nil,
                                                        repeats: true)
    
  }
  
  func invoke() {
    self.callback?()
  }
  
  func cancel() {
    self.timer?.invalidate()
    self.timer = nil
  }
}