//
//  Group.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/4/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Group {
    
    let key: String
    let name: String
    let groupId: String
    let ref: FIRDatabaseReference?
    
    init(name: String, groupId: String, key: String = "") {
        self.key = key
        self.name = name
        self.groupId = groupId
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        groupId = snapshotValue["id"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "groupId": groupId
        ]
    }
    
}
