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
let BLEServiceUUID = CBUUID(string: "EE0C2080-8786-40BA-AB96-99B91AC981D8")
let TestCharUUID = CBUUID(string: "EE0C2084-8786-40BA-AB96-99B91AC981D8")

let TestTwoCharUUID = CBUUID(string: "00001531-1212-EFDE-1523-785FEABCD123")
let TestThreeCharUUID = CBUUID(string: "00001534-1212-EFDE-1523-785FEABCD123")

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
    self.peripheral?.discoverServices(nil)
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
    let uuidsForBTService: [CBUUID] = [TestCharUUID]
    
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
        peripheral.discoverCharacteristics(nil, forService: service)
      }
    }
  }
  
  func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    let buffer: [UInt8] = [0, 1, 2]
    
    print("Charactaristic UUID: \(characteristic.UUID), Value: \(characteristic.value)")
    characteristic.value?.getBytes(UnsafeMutablePointer<UInt8>(buffer), length:buffer.count)
    print("Buffer value: \(buffer)")
  }
  
  func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    //print("\(characteristic.value)")
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
        //if characteristic.UUID != TestCharUUID {
          peripheral.readValueForCharacteristic(characteristic)
          peripheral.setNotifyValue(true, forCharacteristic: characteristic)
          
          // Send notification that Bluetooth is connected and all required characteristics are discovered
          //self.sendBTServiceNotificationWithIsBluetoothConnected(true)
        }
      //}
        self.sendBTServiceNotificationWithIsBluetoothConnected(true)

    }
  }
  
  // Mark: - Private
  
  func writePosition(position: UInt8) {
    
    /******** (1) CODE TO BE ADDED *******/
    
  }
  
  func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
  }
  
}