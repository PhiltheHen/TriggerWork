//
//  Day.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/19/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation

class Day {
    var date: String
    var athletes: [String:Bool]
    
    init(date: String, athletes: [String:Bool]) {
        self.date = date
        self.athletes = athletes
    }
}