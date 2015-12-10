
import Foundation
import UIKit

class ChampionStatus {
    var id: Int
    var name: String?
    var aggregatedStatsDto: AggregatedStatsDto?
    
    init(entry: NSDictionary) {
        
        self.id = (entry["id"] as? Int)!
        if let championName = championsMap[self.id] {
            self.name = championName
        }
        else {
            self.name = "unknown"
        }
        
        if let dict = entry["stats"] as? NSDictionary {
            self.aggregatedStatsDto = AggregatedStatsDto(status: dict)
        }
    }
}

class AggregatedStatsDto {
    var totalSessionsPlayed: Int
    var totalSessionsLost: Int
    var totalSessionsWon: Int
    var totalChampionKills: Int
    var totalMinionKills: Int
    var totalDeathsPerSession: Int
    var totalAssists: Int
    init(status: NSDictionary) {
        self.totalSessionsPlayed = (status["totalSessionsPlayed"] as? Int)!
        self.totalSessionsLost = (status["totalSessionsLost"] as? Int)!
        self.totalSessionsWon = (status["totalSessionsWon"] as? Int)!
        self.totalChampionKills = (status["totalChampionKills"] as? Int)!
        self.totalMinionKills = (status["totalMinionKills"] as? Int)!
        self.totalDeathsPerSession = (status["totalDeathsPerSession"] as? Int)!
        self.totalAssists = (status["totalAssists"] as? Int)!
    }
    
    func getWinRate() -> String {
        return "\(roundToPercent(Double(totalSessionsWon), dec: Double(totalSessionsPlayed)))% \(totalSessionsPlayed) Played"
    }
    
    func getAverageStatus() -> String {
        let averageKills = roundToOneDecimal(Double(totalChampionKills), dec: Double(totalSessionsPlayed))
        let averageDeath = roundToOneDecimal(Double(totalDeathsPerSession), dec: Double(totalSessionsPlayed))
        let averageAssists = roundToOneDecimal(Double(totalAssists), dec: Double(totalSessionsPlayed))
        return "\(averageKills)/\(averageDeath)/\(averageAssists) \(calculateKDA()) KDA"
    }
    
    func roundToOneDecimal(num: Double, dec: Double) -> Double {
        let result = num/dec
        return NSString(format: "%.01f", result).doubleValue
    }
    
    func roundToPercent(num: Double, dec: Double) -> Int {
        let result = num/dec * 100
        return Int(result)
    }
    
    func calculateKDA() -> Double {
        let result = (Double(totalChampionKills) + Double(totalAssists)) / Double(totalDeathsPerSession)
        return NSString(format: "%.02f", result).doubleValue
    }
}
