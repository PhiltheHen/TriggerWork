//
//  BTDeviceTableViewCell.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/6/16.
//  Copyright © 2016 Craftsbury Outdoor Center. All rights reserved.
//

import UIKit

class BTDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var bTDeviceName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
