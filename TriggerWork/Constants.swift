//
//  Constants.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Craftsbury Outdoor Center. All rights reserved.
//

import Foundation
import UIKit

#if STAGING
    let firebaseURL = "https://triggerworkstaging.firebaseIO.com"
#else
    let firebaseURL = "https://triggerwork.firebaseIO.com"
#endif


extension CALayer {
    func setBorderColorFromUIColor(color: UIColor) {
        self.borderColor = color.CGColor
    }
}