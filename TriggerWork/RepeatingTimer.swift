//
//  RepeatingTimer.swift
//  TriggerWork
//
//  Created by Phil Henson on 8/12/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation

class RepeatingTimer: NSObject {
  fileprivate var timer: Timer?
  fileprivate var callback: ((Void) -> Void)?
  
  init(_ delaySeconds: Double, _ callback: @escaping (Void) -> Void) {
    super.init()
    self.callback = callback
    self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(delaySeconds),
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
