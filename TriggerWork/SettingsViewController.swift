//
//  SettingsViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 7/31/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

  @IBOutlet weak var connectedTriggerLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()

      if let peripheralName = btDiscoverySharedInstance.connectedPeripheralName {
        connectedTriggerLabel.text = "Connected to " + peripheralName
      } else {
        connectedTriggerLabel.text = "Connected to Bluetooth Trigger"
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
 

}
