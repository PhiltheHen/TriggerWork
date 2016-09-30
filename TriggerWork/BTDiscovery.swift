//
//  BTDiscovery.swift
//  TriggerWork
//
//  Created by Owen L Brown on 9/24/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//
//  Modified by Phil Henson on 3/9/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import Foundation
import CoreBluetooth

let btDiscoverySharedInstance = BTDiscovery();

class BTDiscovery: NSObject, CBCentralManagerDelegate {
  
  fileprivate var centralManager: CBCentralManager?
  fileprivate var peripheralBLE: CBPeripheral?
  fileprivate var availablePeripherals = [CBPeripheral]()

  override init() {
    super.init()
    
    let centralQueue = DispatchQueue(label: "com.lostnationrd", attributes: [])
    centralManager = CBCentralManager(delegate: self, queue: centralQueue)
  }
  
  func startScanning() {    
    self.sendBTDiscoveryNotificationWithScanStatus(BLEScanStatus.Started)
    
    // Start timer to cancel scan if no devices are found in 8 seconds
    DispatchQueue.main.async(execute: {
      let _ = Timeout(Constants.BLETimeout) {
        self.scanTimeout()
      }
    })
    
    if let central = centralManager {
      central.scanForPeripherals(withServices: [UUID.BLEServiceUUID], options: nil)
    }
  }
  
  func peripheralSelectedAtIndex(_ idx: Int) {
    
    if availablePeripherals.indexExists(idx) {
      
      // Retain the peripheral before trying to connect
      self.peripheralBLE = availablePeripherals[idx]
      
      // Reset service
      self.bleService = nil
      
      // Connect to peripheral
      if let central = centralManager {
        central.connect(self.peripheralBLE!, options: nil)
      }
    }
  }
  
  func stopScanning() {
    self.sendBTDiscoveryNotificationWithScanStatus(BLEScanStatus.Stopped)
    if let central = centralManager {
      central.stopScan()
    }
  }
  
  func scanTimeout() {
    if availablePeripherals.count == 0 {
      self.sendBTDiscoveryNotificationWithScanStatus(BLEScanStatus.TimedOut)
      self.stopScanning()
    }
  }
  
  var connectedPeripheralName: String? {
    get {
      return peripheralBLE?.name
    }
  }
  
  var peripheralCount: Int? {
    get {
      return availablePeripherals.count
    }
  }
  
  func peripheralNameAtIndex(idx: Int) -> String? {
    if availablePeripherals.indexExists(idx) {
      let peripheral = availablePeripherals[idx]
      return peripheral.name
    }
    return ""
  }
  
  func isConnectedToPeripheral() -> Bool {
    return (peripheralBLE != nil)
  }
  
  var bleService: BTService? {
    didSet {
      if let service = self.bleService {
        service.startDiscoveringServices()
      }
    }
  }
  
  // MARK: - CBCentralManagerDelegate
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    // Be sure to retain the peripheral or it will fail during connection.
    
    // Validate peripheral information
    if ((peripheral.name == nil) || (peripheral.name == "")) {
      return
    }
    
    // Add to peripheral array
    if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.disconnected)) {
      if !availablePeripherals.contains(peripheral) {
        availablePeripherals.append(peripheral)
        self.sendBTDiscoveryNotificationWithPeripheralFound()
      }
    }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    
    // Create new service class
    if (peripheral == self.peripheralBLE) {
      self.bleService = BTService(initWithPeripheral: peripheral)
    }
    
    // Stop scanning for new devices
    self.stopScanning()
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    
    // See if it was our peripheral that disconnected
    if (peripheral == self.peripheralBLE) {
      self.bleService = nil;
      self.peripheralBLE = nil;
    }
    
    // Start scanning for new devices
    self.startScanning()
  }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Alert user that peripheral has failed to connect
    }
  
  // MARK: - Private
  
  func clearDevices() {
    self.bleService = nil
    self.peripheralBLE = nil
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
    // Necessary fix at the moment, according to Apple: http://stackoverflow.com/questions/39450534/cbcentralmanager-ios10-and-ios9
    if #available(iOS 10.0, *) {
      switch central.state{
      case CBManagerState.unauthorized:
        print("This app is not authorised to use Bluetooth low energy")
      case CBManagerState.poweredOff:
        self.clearDevices()
        print("Bluetooth is currently powered off.")
      case CBManagerState.poweredOn:
        self.stopScanning()
        self.startScanning()
        print("Bluetooth is currently powered on and available to use.")
      case CBManagerState.resetting:
        self.clearDevices()
        print("Bluetooth resetting")
      default:break
      }
    } else {
      // Fallback on earlier versions
      switch central.state.rawValue {
      case 1: // CBCentralManagerState.resetting :
        self.clearDevices()
        print("Bluetooth resetting")
      case 3: // CBCentralManagerState.unauthorized :
        print("This app is not authorised to use Bluetooth low energy")
      case 4: // CBCentralManagerState.poweredOff:
        self.clearDevices()
        print("Bluetooth is currently powered off.")
      case 5: //CBCentralManagerState.poweredOn:
        self.stopScanning()
        self.startScanning()
        print("Bluetooth is currently powered on and available to use.")
      default:break
      }
    }
  }
  
  func sendBTDiscoveryNotificationWithScanStatus(_ scanStatus: String) {
    let scanDetails = [scanStatus: true]
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.BLEServiceScanStatusNotification), object: self, userInfo: scanDetails)
  }
  
  func sendBTDiscoveryNotificationWithPeripheralFound() {
    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.BLEPeripheralFoundNotification), object: self, userInfo: nil)
  }

}
