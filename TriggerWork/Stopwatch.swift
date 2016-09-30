//
//  Stopwatch.swift
//  TriggerWork
//
//  Created by Phil Henson on 9/28/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit

class Stopwatch: NSObject {
  
  var timerLabel = UILabel()
  var repeatingTimer: RepeatingTimer?
  var startTime = TimeInterval()

  
  /**
   Custom initialization for stopwatch
   */
  init(_ label:UILabel) {
    super.init()
    timerLabel = label
  }
  
  /**
   Start the timer
   */
  func start() {
    repeatingTimer = RepeatingTimer(0.01) {
      DispatchQueue.main.async { [unowned self] in
        self.updateTime(self.timerLabel)
      }
    }
    startTime = NSDate.timeIntervalSinceReferenceDate
  }
  
  /**
   Stop the timer
   */
  func stop() {
    repeatingTimer?.cancel()
  }
  
  /**
   Update timer with time
   */
  func updateTime(_ label: UILabel) {
    let currentTime = NSDate.timeIntervalSinceReferenceDate
    var elapsedTime: TimeInterval = currentTime - startTime
    
    let minutes = UInt8(elapsedTime / 60.0)
    elapsedTime -= (TimeInterval(minutes) * 60)
    
    let seconds = UInt8(elapsedTime)
    elapsedTime -= TimeInterval(seconds)
    
    let fraction = UInt8(elapsedTime * 100)
    
    let strMinutes = String(format: "%02d", minutes)
    let secondsFormat = (seconds < 10 && minutes < 1) ? "%01d" : "%02d"
    let strSeconds = String(format: secondsFormat, seconds)
    let strFraction = String(format: "%02d", fraction)
    
    if minutes < 1 {
      label.text = "\(strSeconds).\(strFraction)"
    } else {
      label.text = "\(strMinutes):\(strSeconds).\(strFraction)"
    }
    
  }
  
}
