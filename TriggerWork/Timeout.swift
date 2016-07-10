//
//  Timeout.swift
//  TriggerWork
//
//  Created by Phil Henson on 4/30/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//  Credit: https://gist.github.com/macu/9a825b53d8b968bd36b8

import Foundation

class Timeout: NSObject {
  private var timer: NSTimer?
  private var callback: (Void -> Void)?
  
  init(_ delaySeconds: Double, _ callback: Void -> Void) {
    super.init()
    self.callback = callback
    self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(delaySeconds),
                                                        target: self,
                                                        selector: #selector(Timeout.invoke),
                                                        userInfo: nil,
                                                        repeats: false)
  }
  
  func invoke() {
    self.callback?()
    // Discard callback and timer.
    self.callback = nil
    self.timer = nil
  }
  
  func cancel() {
    self.timer?.invalidate()
    self.timer = nil
  }
}