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
    
    var areDevicesAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hidden = !areDevicesAvailable

    }

    // MARK: IBActions
    @IBAction func scanDevicesDidTouch(sender: UIButton) {
        
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
        cell.bTDeviceName.text = "UUID or Athlete Name"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
}

// MARK: - UITableViewDelegate
extension BTDiscoveryViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
}
