//
//  SessionTableViewCell.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/19/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit

class SessionTableViewCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Colors.defaultBlackColor()
        collectionView.backgroundColor = Colors.defaultDarkGrayColor()
        collectionView.layer.masksToBounds = true
        collectionView.layer.cornerRadius = 10
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
