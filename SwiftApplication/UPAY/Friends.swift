//
//  Friends.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 9/17/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import Foundation
import CoreData

var friendMgr: FriendManager = FriendManager()

struct Transaction {
    let oweName: String
    let paidName: String
    let amount: Double
}


class Friend {
    
    var name: String
    var amount: Double
    var multiplier: Int
    var pay = 0.0
    var detail = [Transaction]()
    var desc: String
    init(name:String, amount: Double, multiplier: Int, desc: String){
        self.name = name
        self.amount = amount
        self.multiplier = multiplier
        self.desc = desc
    }
    func cleanDetail() {
        self.detail = []
    }
}


class Friends: NSManagedObject {
   
}


