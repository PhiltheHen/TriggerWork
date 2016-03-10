//
//  RecordSessionViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/8/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import UIKit

class RecordSessionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSegueWithIdentifier("loadBluetoothDiscovery", sender: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UI Settings
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
