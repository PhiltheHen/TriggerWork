//
//  BTDiscoveryViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import UIKit
import SVProgressHUD

class BTDiscoveryViewController: UIViewController {
  
  // For use in maintaining cell selection during editing
  var swipeGestureStarted: Bool = false
  var selectedIndexPath: IndexPath?

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyStateView: UIView!
  @IBOutlet weak var continueButton: UIButton!
  var alertPresenter: AlertPresenter? = nil

  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(BTDiscoveryViewController.scanDevices(_:)), for: UIControlEvents.valueChanged)
    
    return refreshControl
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    alertPresenter = AlertPresenter(controller: self)

    tableView.addSubview(refreshControl)
    
    tableView.isHidden = true
    
    // So renaming our triggers by swiping left will maintain any currently selected triggers
    tableView.allowsSelectionDuringEditing = true
    
    continueButton.disable()
    
    // Watch Bluetooth connection
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(BTDiscoveryViewController.connectionChanged(_:)),
                                           name: NSNotification.Name(rawValue: Constants.BLEServiceChangedStatusNotification),
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(BTDiscoveryViewController.peripheralFound(_:)),
                                           name: NSNotification.Name(rawValue: Constants.BLEPeripheralFoundNotification),
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(BTDiscoveryViewController.scanStatusChanged(_:)),
                                           name: NSNotification.Name(rawValue: Constants.BLEServiceScanStatusNotification),
                                           object: nil)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Start the Bluetooth discovery process
    let _ = btDiscoverySharedInstance
    
    if btDiscoverySharedInstance.peripheralCount == 0{
      btDiscoverySharedInstance.startScanning()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopRefresh()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self,
                                              name: NSNotification.Name(rawValue: Constants.BLEServiceChangedStatusNotification),
                                              object: nil)
    
    NotificationCenter.default.removeObserver(self,
                                              name: NSNotification.Name(rawValue: Constants.BLEServiceScanStatusNotification),
                                              object: nil)
    
    NotificationCenter.default.removeObserver(self,
                                              name: NSNotification.Name(rawValue: Constants.BLEPeripheralFoundNotification),
                                              object: nil)
  }
  
  func connectionChanged(_ notification: Notification) {
    // Connection status changed
    
    let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
    
    DispatchQueue.main.async(execute: {
      SVProgressHUD.dismiss()
      self.refreshControl.endRefreshing()
      
      // Enable continue button once BLE connection has succeeded
      if let _: Bool = userInfo[BLEConnectionStatus.Connected] {
        self.continueButton.enable()
        self.continueButton.pumpAnimation()
      }
    });
  }
  
  func peripheralFound(_ notification: Notification) {
    
    // Peripheral found
    DispatchQueue.main.async(execute: {
      SVProgressHUD.dismiss()
      self.refreshControl.endRefreshing()
      self.tableView.reloadData()
      self.hideOrShowTableView()
    });
  }
  
  func hideOrShowTableView() {
    // Hide table view if no peipherals are available
    tableView.isHidden = btDiscoverySharedInstance.peripheralCount == 0
  }
  
  // MARK: IBActions
  @IBAction func scanDevices(_ sender: UIButton) {
    btDiscoverySharedInstance.stopScanning()
    btDiscoverySharedInstance.startScanning()
  }
  
  // MARK: UI Settings
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
  func stopRefresh() {
    btDiscoverySharedInstance.stopScanning()
    SVProgressHUD.dismiss()
    refreshControl.endRefreshing()
  }
  
  // Notification methods
  func scanStatusChanged(_ notification: Notification) {
    
    let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
    
    DispatchQueue.main.async {
      
      if let _: Bool = userInfo[BLEScanStatus.Started] {
        SVProgressHUD.dismiss()
        // Temporarily removing this. Kept showing up when triggers were turned off. Want to keep searching, but without any UI updates.
        //SVProgressHUD.show(withStatus: "Searching for Bluetooth Triggers...")
      }
      
      if let _: Bool = userInfo[BLEScanStatus.Stopped] {
        SVProgressHUD.dismiss()
        self.refreshControl.endRefreshing()
      }
      
      if let _: Bool = userInfo[BLEScanStatus.TimedOut] {
        SVProgressHUD.dismiss()
        self.refreshControl.endRefreshing()
        self.alertPresenter?.presentAlertWithTitle("Unable to find any triggers",
                                             message: "Ensure bluetooth is turned on in settings and you are in range of your BLE trigger") { (_) in
        }
      }
    }
  }
}

// MARK - UITableViewDataSource
extension BTDiscoveryViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! BTDeviceTableViewCell
    cell.bTDeviceName.text = btDiscoverySharedInstance.peripheralNameAtIndex(idx: indexPath.row);
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return btDiscoverySharedInstance.peripheralCount!;
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Select a Bluetooth Device..."
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  }

}

// MARK: - UITableViewDelegate
extension BTDiscoveryViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
    
      swipeGestureStarted = true;
  }
  
  func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
    if swipeGestureStarted {
      swipeGestureStarted = false
      
      tableView.selectRow(at: selectedIndexPath as IndexPath?, animated: true, scrollPosition: .none)
    }
  }

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let rename = UITableViewRowAction(style: .normal, title: "Rename") { action, index in
      self.alertPresenter?.presentTextFieldAlertWithTitle("Rename Trigger",
                                                          message: "",
                                                          placeholderText: btDiscoverySharedInstance.peripheralNameAtIndex(idx: indexPath.row),
                                                          cancelHandler: { (_) in
                                                            self.tableView.isEditing = false
        },
                                                          saveHandler: { (_) in
                                                            
                                                            // Save off the new name for the BLE peripheral
                                                            if let renameTextField = self.alertPresenter?.inputTextField {
                                                              if let newPeripheralName = renameTextField.text {
                                                                UserDefaults.savePeripheralName(btDiscoverySharedInstance.peripheralUUIDAtIndex(indexPath.row)!, name: newPeripheralName)
                                                                self.tableView.reloadData()
                                                              }
                                                            }
      })
    }
    
    rename.backgroundColor = UIColor.orange
    
    return [rename]
  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    if let sectionTitleLabel = header.textLabel {
      sectionTitleLabel.font = Fonts.defaultRegularFontWithSize(13.0)
      sectionTitleLabel.textColor = UIColor.white;
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    selectedIndexPath = indexPath
    
    // Stop scanning for new peripherals once user selects one to connect
    btDiscoverySharedInstance.stopScanning()
    
    DispatchQueue.main.async(execute: {
      SVProgressHUD.show()
    })
    
    btDiscoverySharedInstance.peripheralSelectedAtIndex(indexPath.row)
  }
  
}
