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
  func didUpdateTriggerValue(value: String, interrupt: Bool)
}

class BTService: NSObject, CBPeripheralDelegate {
  
  weak var delegate: BTServiceDelegate?
  var peripheral: CBPeripheral?
  var broadcastingCharacteristic: CBCharacteristic?
  var impulseCharacteristic: CBCharacteristic?
  var cachedValue: Data?
  var cachedValueString: String = "0"
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
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
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
      if service.uuid == UUID.BLEServiceUUID {
        // Notify that our service has been found
        peripheral.discoverCharacteristics(uuidsForBTService, for: service)
      }
    }
  }
  
  // Want to manually control the data retrieval instead of relying on automatic updates from the receiver
  func fetchBroadcastingCharacteristicValue() {
   
    
    if let characteristic = broadcastingCharacteristic {
      // This method calls the peripheral:didUpdateValueForCharacteristic:error: method
      peripheral?.readValue(for: characteristic)
    }
 
    
    //if let impulse = impulseCharacteristic {
    //  peripheral?.readValue(for: impulse)
    //}
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    let buffer: [UInt8] = [0, 1]
    
    let value: Data?
    
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
    
    // Cache latest value in case we can't read from the characteristic
    cachedValue = characteristic.value
    
    // Value guaranteed to not be nil
    (value! as NSData).getBytes(UnsafeMutablePointer<UInt8>(mutating: buffer), length:buffer.count)

    print("Buffer Value: \(buffer)")
    
    // Data payload for the force characteristic changes based on whether or not an interrupt was detected. We check the first element of the buffer array for that change.
    
    if (buffer[0] > 0) {
      print("Interrupt Fired")
      self.delegate?.didUpdateTriggerValue(value: cachedValueString, interrupt: true)
    } else {
      // Need to keep track of latest force value that makes sense
      // Can't get the exact force value at the time of interrupt
      cachedValueString = String(buffer[1])
      self.delegate?.didUpdateTriggerValue(value: cachedValueString, interrupt: false)
    }
    
    
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    //print("Charactaristic UUID: \(characteristic.UUID), Value: \(characteristic.value)")
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if let characteristics = service.characteristics {
      
      for characteristic in characteristics {
        if characteristic.uuid == UUID.MeasurementCharUUID {
          
          // Saving this variable so we can query the characteristic for its value at any point
          broadcastingCharacteristic = characteristic
          
          // Set up notifications for updates to the characteristic - not going this route at the moment
          //peripheral.setNotifyValue(true, forCharacteristic: characteristic)
          
          self.sendBTServiceNotificationWithIsBluetoothConnected(true)
          
        } else if characteristic.uuid == UUID.ShotFiredCharUUID {
          // TODO: Not implemented yet
          impulseCharacteristic = characteristic
          peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }
  }
  
  // Mark: - Private
  func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
  }
  
}

