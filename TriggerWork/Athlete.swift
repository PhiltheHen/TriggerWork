//
//  Athlete.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/17/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit

class Athlete {
    var id: String
    var name: String
    var email: String
    var password: String
    var shootingDays: [String:String]
    
    convenience init(id: String) {
        self.init(id: id, name: "", email: "", password: "")
    }
    
    init(id: String, name: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.shootingDays = [String:String]()
    }
}
