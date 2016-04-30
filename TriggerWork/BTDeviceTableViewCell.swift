//
//  BTDeviceTableViewCell.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/6/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import UIKit

class BTDeviceTableViewCell: UITableViewCell {
  
  @IBOutlet weak var bTDeviceName: UILabel!
  @IBOutlet weak var cellCheckmark: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    cellCheckmark.hidden = true
    self.selectionStyle = .None
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    cellCheckmark.hidden = !selected
    cellCheckmark.pumpAnimation()
  }
  
}
