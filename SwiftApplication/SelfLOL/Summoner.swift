//
//  Summoner.swift
//  SelfLOL
//
//  Created by Lit Wa Yuen on 10/18/15.
//  Copyright © 2015 lit.wa.yuen. All rights reserved.
//

import Foundation

class Summoner {
    var id: CLong
    var name: String
    var profileIconId: Int
    var revisionDate: CLong
    var summonerLevel: Int
    var rank: String?
    
    init(data: NSDictionary) {
        self.id = (data["id"] as? CLong)!
        self.name = (data["name"] as? String)!
        self.profileIconId = (data["profileIconId"] as? Int)!
        self.revisionDate = (data["revisionDate"] as? CLong)!
        self.summonerLevel = (data["summonerLevel"] as? Int)!
        
    }
    
  
}
