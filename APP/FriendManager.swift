//
//  FriendManager.swift
//  UPAY
//
//  Created by Lit Wa Yuen on 8/22/15.
//  Copyright (c) 2015 CS320. All rights reserved.
//

import UIKit

var friendMgr: FriendManager = FriendManager()

struct Friend {
    let name: String
    let amount: Double
}

class FriendManager: NSObject {
   var friends = [Friend]()
    
    func addFriend(name: String, amount: Double) {
        friends.append(Friend(name: name, amount: amount))
    }
    

}
