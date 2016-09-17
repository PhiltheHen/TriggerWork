//
//  ShotCollectionViewCell.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/19/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit

class ShotCollectionViewCell: UICollectionViewCell {
    
    var shadowLayer: CAShapeLayer!
    var bgView: UIView!
    var timeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Make circular subview
        let bgFrame = CGRect(x: frame.origin.x+5, y: frame.origin.y+5, width: frame.size.width-5, height: frame.size.height-5)
        bgView = UIView(frame: bgFrame)
        bgView.layer.cornerRadius = bgFrame.size.height/2
        addSubview(bgView)
        
        // Add time label
        let labelFrame = CGRect(x: bgView.frame.origin.x, y: (bgView.frame.size.height/2) - 5, width: bgView.frame.size.width, height: 10)
        timeLabel = UILabel(frame: labelFrame)
        timeLabel.font = Fonts.defaultLightFontWithSize(12.0)
        timeLabel.textColor = UIColor.white
        addSubview(timeLabel)
        
        // Add drop shadow
        shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bgView.bounds, cornerRadius: bgView.layer.cornerRadius).cgPath
        shadowLayer.fillColor = Colors.defaultGreenColor().cgColor
        
        shadowLayer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 2
        shadowLayer.masksToBounds = false
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
}
