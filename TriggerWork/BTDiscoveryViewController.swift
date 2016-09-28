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
    refreshControl.addTarget(self, action: #selector(BTDiscoveryViewController.scanDevices(_:)), for: UIControlEvents.valueChanged)
    
    return refreshControl
  }()
  
  //MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.addSubview(refreshControl)
    
    tableView.isHidden = true
    
    continueButton.disable()
    
    // Watch Bluetooth connection
    NotificationCenter.default.addObserver(self, selector: #selector(BTDiscoveryViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: Constants.BLEServiceChangedStatusNotification), object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(BTDiscoveryViewController.scanStatusChanged(_:)), name: NSNotification.Name(rawValue: Constants.BLEServiceScanStatusNotification), object: nil)
    
    // Start the Bluetooth discovery process
    let _ = btDiscoverySharedInstance
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopRefresh()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.BLEServiceChangedStatusNotification), object: nil)
    
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.BLEServiceScanStatusNotification), object: nil)
  }
  
  func connectionChanged(_ notification: Notification) {
    // Connection status changed
    
    let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
    
    DispatchQueue.main.async(execute: {
      SVProgressHUD.dismiss()
      self.refreshControl.endRefreshing()
      
      if let _: Bool = userInfo[BLEConnectionStatus.Connected] {
        self.hideOrShowTableView()
        self.tableView.reloadData()
      }
    });
  }
  
  func hideOrShowTableView() {
    tableView.isHidden = !(btDiscoverySharedInstance.isConnectedToPeripheral())
  }
  
  // MARK: IBActions
  @IBAction func scanDevices(_ sender: UIButton) {
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
        self.emptyStateView.isHidden = true
        SVProgressHUD.dismiss()
        SVProgressHUD.show(withStatus: "Searching for Bluetooth Triggers...")
      }
      
      if let _: Bool = userInfo[BLEScanStatus.Stopped] {
        self.emptyStateView.isHidden = false
        SVProgressHUD.dismiss()
        self.refreshControl.endRefreshing()
      }
      
      if let _: Bool = userInfo[BLEScanStatus.TimedOut] {
        self.emptyStateView.isHidden = false
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
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! BTDeviceTableViewCell
    if let name = btDiscoverySharedInstance.peripheralName {
      cell.bTDeviceName.text = "\(name)"
    } else {
      cell.bTDeviceName.text = "Unkonwn";
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1;
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Select a Bluetooth Device..."
  }
}

// MARK: - UITableViewDelegate
extension BTDiscoveryViewController: UITableViewDelegate {
  
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
    continueButton.enable()
    continueButton.pumpAnimation()
  }
  
}
