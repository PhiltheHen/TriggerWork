//
//  BTDiscoveryViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import UIKit

class BTDiscoveryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hidden = true
        
        // Watch Bluetooth connection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BTDiscoveryViewController.connectionChanged(_:)), name: BLEServiceChangedStatusNotification, object: nil)
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BLEServiceChangedStatusNotification, object: nil)
    }
    
    func connectionChanged(notification: NSNotification) {
        // Connection status changed
        
        let userInfo = notification.userInfo as! [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if let _: Bool = userInfo[BLEConnectionStatus.Connected] {
                self.hideOrShowTableView()
                self.tableView.reloadData()
            }
        });
    }
    
    func hideOrShowTableView() {
        tableView.hidden = (btDiscoverySharedInstance.isConnectedToPeripheral())
    }
    
    // MARK: IBActions
    @IBAction func scanDevicesDidTouch(sender: UIButton) {
        btDiscoverySharedInstance
    }
    
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UI Settings
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

// MARK - UITableViewDataSource
extension BTDiscoveryViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! BTDeviceTableViewCell
        cell.bTDeviceName.text = btDiscoverySharedInstance.peripheralName
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
}

// MARK: - UITableViewDelegate
extension BTDiscoveryViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
}
