//
//  Action.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/9/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Action {
    
    let key: String
    let createdBy: String
    var amount: Double
    let name: String
    let createdDate: NSDate
    let description: String
    let ref: FIRDatabaseReference?
    
    init(name: String, amount: Double, createdBy: String, key: String = "") {
        self.key = key
        self.amount = amount
        self.name = name
        self.createdBy = createdBy
        self.createdDate = NSDate()
        self.description = ""
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        amount = snapshotValue["amount"] as! Double
        createdBy = snapshotValue["createdBy"] as! String
        name = snapshotValue["name"] as! String
        description = snapshotValue["description"] as! String
        let date = snapshotValue["createDate"] as! Double
        createdDate = NSDate(timeIntervalSince1970: date)
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "amount": amount,
            "createdBy": createdBy
        ]
    }
    
}
