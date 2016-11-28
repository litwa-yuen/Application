//
//  User.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/4/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import Foundation
import Firebase

enum FriendType: String {
    case FRIEND="FRIEND", REQUEST="REQUEST", NEUTRAL="NEUTRAL", RESPONSE="RESPONSE", SELF="SELF"
}


struct User {
    
    let uid: String
    let email: String
    let name: String
    let type: FriendType
    let friends: [User]?
    let groups: [Group]?
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
        name = authData.displayName!
        type = FriendType.SELF
        friends = nil
        groups = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        uid = (snapshot.value as? NSDictionary)?["uid"] as? String ?? ""
        name = (snapshot.value as? NSDictionary)?["name"] as? String ?? ""
        email = (snapshot.value as? NSDictionary)?["email"] as? String ?? ""
        let myType = (snapshot.value as? NSDictionary)?["type"] as? String ?? ""
        if myType != "" {
            type = FriendType(rawValue: myType)!
        }
        else {
            type = FriendType.SELF
        }
        friends = nil
        groups = nil
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
        type = FriendType.SELF
        self.name = ""
        self.friends = nil
        self.groups = nil
    }
    
}
