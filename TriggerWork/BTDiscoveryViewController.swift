//
//  BTDiscoveryViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Craftsbury Outdoor Center. All rights reserved.
//

import UIKit

class BTDiscoveryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    
    var areDevicesAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: create BTUtility class
        
        //BTUtility.checkForDevices();
        
        tableView.hidden = !areDevicesAvailable

    }

    @IBAction func scanDevicesDidTouch(sender: UIButton) {
        
    }
    
    // MARK: UI Settings
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
