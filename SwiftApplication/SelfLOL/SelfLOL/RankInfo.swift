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
        self.name = getValue(data, fieldName: "name")!
        self.queue = getValue(data, fieldName: "queue")!
        self.tier = getValue(data, fieldName: "tier")!
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
        
        self.division = getValue(entry, fieldName: "division")!
        self.leaguePoints = getValue(entry, fieldName: "leaguePoints")!
        self.losses = getValue(entry, fieldName: "losses")!
        self.wins = getValue(entry, fieldName: "wins")!
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
        self.losses = getValue(series, fieldName: "losses")!
        self.wins = getValue(series, fieldName: "wins")!
        self.target = getValue(series, fieldName: "target")!
        self.progress = getValue(series, fieldName: "progress")!
    }
}