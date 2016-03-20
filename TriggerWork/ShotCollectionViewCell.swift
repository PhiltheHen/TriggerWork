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
        let bgFrame = CGRectMake(frame.origin.x+5, frame.origin.y+5, frame.size.width-5, frame.size.height-5)
        bgView = UIView(frame: bgFrame)
        bgView.layer.cornerRadius = bgFrame.size.height/2
        addSubview(bgView)
        
        // Add time label
        let labelFrame = CGRectMake(bgView.frame.origin.x, (bgView.frame.size.height/2) - 5, bgView.frame.size.width, 10)
        timeLabel = UILabel(frame: labelFrame)
        timeLabel.font = Fonts.defaultLightFontWithSize(12.0)
        timeLabel.textColor = UIColor.whiteColor()
        addSubview(timeLabel)
        
        // Add drop shadow
        shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bgView.bounds, cornerRadius: bgView.layer.cornerRadius).CGPath
        shadowLayer.fillColor = Colors.defaultGreenColor().CGColor
        
        shadowLayer.shadowColor = UIColor.darkGrayColor().CGColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 2
        shadowLayer.masksToBounds = false
        
        layer.insertSublayer(shadowLayer, atIndex: 0)
    }
}
