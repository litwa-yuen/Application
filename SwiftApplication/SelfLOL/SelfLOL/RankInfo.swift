import Foundation
import UIKit

class RankInfo {
    var entry: LeagueEntryDto?
    var name: String
    var queue: String
    var tier: String
    var image: UIImage? {
        let rank = getRank().lowercaseString
        if let image = UIImage(named: rank){
            return image
        }
        else {
            return UIImage(named: "provisional")
        }
    }
    
    init(data: NSDictionary){
        if let array = data["entries"] as? NSArray {
            self.entry = LeagueEntryDto(entry: array[0] as! NSDictionary)
        }
        self.name = (data["name"] as? String)!
        self.queue = (data["queue"] as? String)!
        self.tier = (data["tier"] as? String)!
    }
    
    func getRankWithLP() -> String {
        var seriesDisplay: String = ""
        if let series = entry?.miniSeries {
            for c in series.progress.characters {
                switch(c){
                    case "W": seriesDisplay += "✅"
                    case "L": seriesDisplay += "❎"
                default: seriesDisplay += "◻️"
                }
            }
        }
        
        if entry != nil && seriesDisplay == ""{
            seriesDisplay = "\((entry?.leaguePoints)!) LP"
        }
        if tier == "provisional" {
            return "Unranked"
        }
        else if tier == "MASTER" || tier == "CHALLENGER" {
            return "\(tier) (\(seriesDisplay))"
        }
        else {
            return "\(tier) \((entry?.division)!) (\(seriesDisplay))"
        }
    }
    
    func getRank() -> String {
        if tier == "MASTER" || tier == "CHALLENGER" || tier == "provisional" {
            return "\(tier)"
        }
        else {
            return "\(tier) \((entry?.division)!)"
        }
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