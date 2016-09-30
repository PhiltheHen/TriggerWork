//
//  FIRDataManager.swift
//  TriggerWork
//
//  Created by Phil Henson on 7/10/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit

class FIRDataManager: NSObject {
  // Firebase
  var ref : FIRDatabaseReference!
  let currentUser : FIRUser!
  let userID : String!
  
  init(ref: FIRDatabaseReference, currentUser:FIRUser) {
    self.ref = ref
    self.currentUser = currentUser
    self.userID = currentUser.uid
    super.init()
  }
  
  override init() {
    self.ref = FIRDatabase.database().reference()
    self.currentUser = FIRAuth.auth()?.currentUser
    self.userID = currentUser?.uid
    super.init()
  }
  
  /**
   Save data to current firebase database reference
   */
  func saveSessionWithShotData(_ data:[[String:String]]) {
    
    let key = ref.child("sessions").childByAutoId().key
    let session : [String : AnyObject] = ["uid" : userID as AnyObject,
                                          "date" : Date.currentDateToString() as AnyObject,
                                          "shot_data" : data as AnyObject]
    
    let childUpdates = ["/sessions/\(key)" : session,
                        "/user-sessions/\(userID!)/\(key)/" : session]
    ref.updateChildValues(childUpdates)
  }

  /**
   Retrieve data once with a specific session ID
   */
  func retrieveDataFromSessionWithID(_ sessionID:String, completion:@escaping (_ result: NSArray) -> Void) {
    ref.child("sessions").child(sessionID).observeSingleEvent(of: .value, with: {(snapshot) in
      let data = snapshot.value as! NSArray
      
      /* Print data for testing (reference)
      for i in 0..<data.count {
        print("key: \(data[i]["time"]!), value: \(data[i]["value"]!)")
      }
       */
      
      completion(data)
    })
  }
  
  /**
   Retrieve data for specific user ID and create listener for changes to database
   */
  func retrieveDataForUser(_ userID:String, completion:@escaping (_ result: NSDictionary) -> Void) {
    ref.child("/user-sessions/\(userID)").observe(FIRDataEventType.value, with: { (snapshot) in
      if let sessions = snapshot.value as? [String : AnyObject] {
        completion(sessions as NSDictionary)
      }
    })
  }
}

/********* Reference *********/

/*

 Sample data for testing SAVE:
 
 [["time" : "0:00.1",
 "value" : "10"],
 ["time" : "0:00.9",
 "value" : "30"],
 ["time" : "0:01.3",
 "value" : "50"],
 ["time" : "0:02.1",
 "value" : "60"],
 ["time" : "0:02.8",
 "value" : "70"],
 ["time" : "0:03.5",
 "value" : "80"],
 ["time" : "0:04.2",
 "value" : "85"],
 ["time" : "0:05.0",
 "value" : "89"],
 ["time" : "0:06.8",
 "value" : "91"]]
 
Sample code for testing RETRIEVE:

 for i in 0..<data.count {
  print("key: \(data[i]["time"]!), value: \(data[i]["value"]!)")
 }

*/
