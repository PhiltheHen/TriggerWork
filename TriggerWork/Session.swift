//
//  Session.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/19/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import Foundation

class Session {
    var date: String
    var athleteId: String
    var sessionNum: String
    var avgShotTime: String
    var shots: [String:Shot]
    
    init(date: String, athleteId: String, sessionNum: String) {
        self.date = date
        self.athleteId = athleteId
        self.sessionNum = sessionNum
        self.avgShotTime = ""
        self.shots = [String:Shot]()
    }
}