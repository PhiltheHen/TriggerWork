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
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyStateView: UIView!
  @IBOutlet weak var continueButton: UIButton!
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(BTDiscoveryViewController.scanDevices(_:)), forControlEvents: UIControlEvents.ValueChanged)
    
    return refreshControl
  }()
  
  //MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.addSubview(refreshControl)
    
    tableView.hidden = true
    
    continueButton.disable()
    
    // Watch Bluetooth connection
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BTDiscoveryViewController.connectionChanged(_:)), name: Constants.BLEServiceChangedStatusNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BTDiscoveryViewController.scanStatusChanged(_:)), name: Constants.BLEServiceScanStatusNotification, object: nil)
    
    // Start the Bluetooth discovery process
    btDiscoverySharedInstance
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    stopRefresh()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.BLEServiceChangedStatusNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.BLEServiceScanStatusNotification, object: nil)
  }
  
  func connectionChanged(notification: NSNotification) {
    // Connection status changed
    
    let userInfo = notification.userInfo as! [String: Bool]
    
    dispatch_async(dispatch_get_main_queue(), {
      SVProgressHUD.dismiss()
      self.refreshControl.endRefreshing()
      
      if let _: Bool = userInfo[BLEConnectionStatus.Connected] {
        self.hideOrShowTableView()
        self.tableView.reloadData()
      }
    });
  }
  
  func hideOrShowTableView() {
    tableView.hidden = !(btDiscoverySharedInstance.isConnectedToPeripheral())
  }
  
  // MARK: IBActions
  @IBAction func scanDevices(sender: UIButton) {
    btDiscoverySharedInstance.startScanning()
  }
  
  // MARK: UI Settings
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  func stopRefresh() {
    btDiscoverySharedInstance.stopScanning()
    SVProgressHUD.dismiss()
    refreshControl.endRefreshing()
  }
  
  // Notification methods
  func scanStatusChanged(notification: NSNotification) {
    
    let userInfo = notification.userInfo as! [String: Bool]
    
    dispatch_async(dispatch_get_main_queue()) {
      
      if let _: Bool = userInfo[BLEScanStatus.Started] {
        self.emptyStateView.hidden = true
        SVProgressHUD.showWithStatus("Searching for Bluetooth Triggers...")
      }
      
      if let _: Bool = userInfo[BLEScanStatus.Stopped] {
        self.emptyStateView.hidden = false
        SVProgressHUD.dismiss()
        self.refreshControl.endRefreshing()
      }
      
      if let _: Bool = userInfo[BLEScanStatus.TimedOut] {
        self.emptyStateView.hidden = false
        SVProgressHUD.dismiss()
        self.refreshControl.endRefreshing()
        let alertPresenter = AlertPresenter(controller: self)
        alertPresenter.presentAlertWithTitle("Unable to connect to a trigger",
                                             message: "Ensure bluetooth is turned on in settings and you are in range of your BLE trigger") { (_) in
        }
      }
    }
  }
}

// MARK - UITableViewDataSource
extension BTDiscoveryViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! BTDeviceTableViewCell
    if let name = btDiscoverySharedInstance.peripheralName {
      cell.bTDeviceName.text = "\(name)"
    } else {
      cell.bTDeviceName.text = "Unkonwn";
    }
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1;
  }
}

// MARK: - UITableViewDelegate
extension BTDiscoveryViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    if let sectionTitleLabel = header.textLabel {
      sectionTitleLabel.font = Fonts.defaultRegularFontWithSize(13.0)
      sectionTitleLabel.textColor = UIColor.whiteColor();
    }
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Select a Bluetooth Device..."
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 80.0
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    continueButton.enable()
    continueButton.pumpAnimation()
  }
  
}
