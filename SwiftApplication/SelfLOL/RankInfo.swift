//
//  RankInfo.swift
//  SelfLOL
//
//  Created by Lit Wa Yuen on 10/18/15.
//  Copyright © 2015 lit.wa.yuen. All rights reserved.
//

import Foundation

class RankInfo {
    var entry: LeagueEntryDto?
    var name: String
    var queue: String
    var tier: String
    
    init(data: NSDictionary){
        if let array = data["entries"] as? NSArray {
            self.entry = LeagueEntryDto(entry: array[0] as! NSDictionary)
        }
        self.name = (data["name"] as? String)!
        self.queue = (data["queue"] as? String)!
        self.tier = (data["tier"] as? String)!
    }
}

class LeagueEntryDto {
    var division: String
    var leaguePoints: Int
    var losses: Int
    var wins: Int
    var miniSeries: MiniSeriesDto?
    
    init(entry: NSDictionary) {
        
        self.division = (entry["division"] as? String)!
        self.leaguePoints = (entry["leaguePoints"] as? Int)!
        self.losses = (entry["losses"] as? Int)!
        self.wins = (entry["wins"] as? Int)!
        if let dict = entry["miniSeries"] as? NSDictionary {
            self.miniSeries = MiniSeriesDto(series: dict)
        }
    }
    
}

class MiniSeriesDto {
    var losses: Int
    var progress: String
    var target: Int
    var wins: Int
    
    init(series: NSDictionary) {
        self.losses = (series["losses"] as? Int)!
        self.wins = (series["wins"] as? Int)!
        self.target = (series["target"] as? Int)!
        self.progress = (series["progress"] as? String)!
    }
}