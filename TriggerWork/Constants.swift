//
//  Constants.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/5/16.
//  Copyright © 2016 Lost Nation R & D. All rights reserved.
//

import Foundation
import UIKit
import SwiftHEXColors

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

struct Fonts {
    
    static func defaultLightFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "MyriadPro-Light", size: size)!
    }
    
    static func defaultRegularFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "MyriadPro-Bold", size: size)!
    }
}

struct Colors {
    static func defaultDarkGrayColor() -> UIColor {
        return UIColor(hexString: "#898989")!
    }
    
    static func defaultGreenColor() -> UIColor {
        return UIColor(hexString: "#4BB48F")!
    }
    
    static func defaultBlackColor() -> UIColor {
        return UIColor(hexString: "#26252D")!
    }
}