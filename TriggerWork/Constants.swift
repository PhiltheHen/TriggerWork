//
//  Constants.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import Foundation
import UIKit
import SwiftHEXColors
import CoreBluetooth

struct Constants {
  static let CorePlotIdentifier = "DataSourcePlot"
  static let BLETimeout = 5.0 // seconds
  static let BLEDataUpdateInterval = 0.1 // seconds
  static let MaxDataPoints = 50
  static let MaxYValue = 100
  static let MinYValue = -10
  static let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"
  static let BLEServiceScanStatusNotification = "kBLEServiceScanStatusNotification"

}

struct UUID {
  static let BLEServiceUUID = CBUUID(string: "180D")
  static let MeasurementCharUUID = CBUUID(string: "2A37")
  static let ShotFiredCharUUID = CBUUID(string: "2A38")
}

struct Fonts {
  
  static func defaultLightFontWithSize(size: CGFloat) -> UIFont {
    return UIFont(name: "MyriadPro-Light", size: size)!
  }
  
  static func defaultRegularFontWithSize(size: CGFloat) -> UIFont {
    return UIFont(name: "MyriadPro-Bold", size: size)!
  }
}

struct Colors {
  static func defaultDarkGrayColor() -> UIColor {
    return UIColor(hexString: "#898989")!
  }
  
  static func defaultGreenColor() -> UIColor {
    return UIColor(hexString: "#4BB48F")!
  }
  
  static func defaultRedColor() -> UIColor {
    return UIColor(hexString: "#D64541")!
  }
  
  static func defaultBlackColor() -> UIColor {
    return UIColor(hexString: "#26252D")!
  }
}

struct Helpers {
  static func sortedKeysAndValuesFromDict(dict: Dictionary<String, AnyObject>) -> [(String, AnyObject)] {
    return dict.sort { $0.0 < $1.0 }
  }
}

struct BLEConnectionStatus {
  static let Connected = "isConnected"
}

struct BLEScanStatus {
  static let Started = "started"
  static let Stopped = "stopped"
  static let TimedOut = "timedOut"
}

