//
//  BTService.swift
//  TriggerWork
//
//  Created by Owen L Brown on 10/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
// 
//  Modified by Phil Henson on 3/9/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BLEServiceUUID = CBUUID(string: "180D")
let MeasurementCharUUID = CBUUID(string: "2A37")
let LocationCharUUID = CBUUID(string: "2A38")

let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {
  var peripheral: CBPeripheral?
  
  init(initWithPeripheral peripheral: CBPeripheral) {
    super.init()
    
    self.peripheral = peripheral
    self.peripheral?.delegate = self
  }
  
  deinit {
    self.reset()
  }
  
  func startDiscoveringServices() {
    self.peripheral?.discoverServices([BLEServiceUUID])
  }
  
  func reset() {
    if peripheral != nil {
      peripheral = nil
    }
    
    // Deallocating therefore send notification
    self.sendBTServiceNotificationWithIsBluetoothConnected(false)
  }
  
  // Mark: - CBPeripheralDelegate
  
  func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    let uuidsForBTService: [CBUUID] = [MeasurementCharUUID, LocationCharUUID]
    
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
      // No Services
      return
    }
    
    for service in peripheral.services! {
      if service.UUID == BLEServiceUUID {
        // Notify that our service has been found
        peripheral.discoverCharacteristics(uuidsForBTService, forService: service)
      }
    }
  }
  
  func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    let buffer: [UInt8] = [0, 1, 2]
    
    guard let rawValue = characteristic.value else { return }
    
    print("Charactaristic UUID: \(characteristic.UUID), Value: \(rawValue)")
    
    rawValue.getBytes(UnsafeMutablePointer<UInt8>(buffer), length:buffer.count)
    print("Buffer value: \(buffer)")
  }
  
  func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    print("Charactaristic UUID: \(characteristic.UUID), Value: \(characteristic.value)")
  }
  
  func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if let characteristics = service.characteristics {
      
      for characteristic in characteristics {
        //print("\(characteristic.UUID)")
        if characteristic.UUID == MeasurementCharUUID {
          peripheral.setNotifyValue(true, forCharacteristic: characteristic)
          self.sendBTServiceNotificationWithIsBluetoothConnected(true)
        } else if characteristic.UUID == LocationCharUUID {
          //peripheral.readValueForCharacteristic(characteristic)
        }
      }
    }
  }
  
  // Mark: - Private
  func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
  }
  
}