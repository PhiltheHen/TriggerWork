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
  var broadcastingCharacteristic: CBCharacteristic?
  var cachedValue: NSData?
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
  
  // Want to manually control the data retrieval instead of relying on automatic updates from the receiver
  func fetchBroadcastingCharacteristicValue() {
    if let characteristic = broadcastingCharacteristic {
      
      // This method calls the peripheral:didUpdateValueForCharacteristic:error: method
      peripheral?.readValueForCharacteristic(characteristic)
    }
  }
  
  func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    let buffer: [UInt8] = [0, 1, 2]
    
    let value: NSData?
    
    // Want to ensure value is not nil
    if let rawValue = characteristic.value {
      value = rawValue
    } else {
      if (cachedValue != nil) {
        value = cachedValue
      } else {
        return
      }
    }
    
    if characteristic.UUID == UUID.ShotFiredCharUUID {
      print("Shot Fired Value: \(characteristic.value)")
    }
    
    // Cache latest value in case we can't read from the characteristic
    cachedValue = characteristic.value
    
    // Value guaranteed to not be nil
    value!.getBytes(UnsafeMutablePointer<UInt8>(buffer), length:buffer.count)
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
          
          // Saving this variable so we can query the characteristic for its value at any point
          broadcastingCharacteristic = characteristic
          
          // Set up notifications for updates to the characteristic - not going this route at the moment
          //peripheral.setNotifyValue(true, forCharacteristic: characteristic)
          
          self.sendBTServiceNotificationWithIsBluetoothConnected(true)
          
        } else if characteristic.UUID == UUID.ShotFiredCharUUID {
          // TODO: Not implemented yet
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

