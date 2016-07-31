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

// MARK: - BTService Delegate Methods
protocol BTServiceDelegate: class {
  func didUpdateTriggerValue(value: String)
}

class BTService: NSObject, CBPeripheralDelegate {
  
  weak var delegate: BTServiceDelegate?
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
    self.peripheral?.discoverServices([UUID.BLEServiceUUID])
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
    let uuidsForBTService: [CBUUID] = [UUID.MeasurementCharUUID, UUID.ShotFiredCharUUID]
    
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
      if service.UUID == UUID.BLEServiceUUID {
        // Notify that our service has been found
        peripheral.discoverCharacteristics(uuidsForBTService, forService: service)
      }
    }
  }
  
  func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    let buffer: [UInt8] = [0, 1, 2]
    
    guard let rawValue = characteristic.value else { return }
    
    if characteristic.UUID == UUID.ShotFiredCharUUID {
      print("Shot Fired Value: \(characteristic.value)")
    }
    
    rawValue.getBytes(UnsafeMutablePointer<UInt8>(buffer), length:buffer.count)
    self.delegate?.didUpdateTriggerValue(String(buffer[1]))
  }
  
  func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    //print("Charactaristic UUID: \(characteristic.UUID), Value: \(characteristic.value)")
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
        if characteristic.UUID == UUID.MeasurementCharUUID {
          peripheral.setNotifyValue(true, forCharacteristic: characteristic)
          self.sendBTServiceNotificationWithIsBluetoothConnected(true)
        } else if characteristic.UUID == UUID.ShotFiredCharUUID {
          peripheral.setNotifyValue(true, forCharacteristic: characteristic)
        }
      }
    }
  }
  
  // Mark: - Private
  func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NSNotificationCenter.defaultCenter().postNotificationName(Constants.BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
  }
  
}

