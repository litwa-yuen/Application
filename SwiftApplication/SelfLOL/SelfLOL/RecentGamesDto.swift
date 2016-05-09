import Foundation

class GameDto {
    var championId: Int
    var createDate: NSNumber
    var gameId: NSNumber
    var spell1: Int
    var spell2: Int
    var teamId: Int
    var subType: String
    var fellowPlayers: [PlayerDto]?
    var stats: RawStatsDto?
    
    init(entry: NSDictionary){
        self.championId = (entry["championId"] as? Int)!
        self.createDate = (entry["createDate"] as? NSNumber)!
        self.gameId = (entry["gameId"] as? NSNumber)!
        self.spell1 = (entry["spell1"] as? Int)!
        self.spell2 = (entry["spell2"] as? Int)!
        self.teamId = (entry["teamId"] as? Int)!
        self.subType = (entry["subType"] as? String)!
        if let fellowPlayers = entry["fellowPlayers"] as? NSArray {
            self.fellowPlayers = []
            for player in fellowPlayers {
                self.fellowPlayers?.append(PlayerDto(player: player  as! NSDictionary))
            }
        }
        if let dict = entry["stats"] as? NSDictionary {
            self.stats = RawStatsDto(status: dict)
        }

    }
}

class RawStatsDto {
    var assists: Int
    var championsKilled: Int
    var numDeaths: Int
    var timePlayed: Int
    var win: Bool
    var goldEarned: Int
    var minionsKilled: Int
    var item0: Int?
    var item1: Int?
    var item2: Int?
    var item3: Int?
    var item4: Int?
    var item5: Int?
    var item6: Int?
    
    init(status: NSDictionary) {
        
        self.minionsKilled = status["minionsKilled"] as? Int ?? 0

        self.goldEarned = status["goldEarned"] as? Int ?? 0

        self.timePlayed = status["timePlayed"] as? Int ?? 0
        
        self.assists = status["assists"] as? Int ?? 0
        
        if let killed = status["championsKilled"] as? Int {
            self.championsKilled = killed
        }
        else if  let killed = status["kills"] as? Int {
            self.championsKilled = killed
        }
        else {
            self.championsKilled = 0
        }
        if let death = status["numDeaths"] as? Int {
            self.numDeaths = death
        }
        else if let death = status["deaths"] as? Int {
            self.numDeaths = death
        }
        else {
            self.numDeaths = 0
        }
        
        self.win = status["win"] as? Bool ?? (status["winner"] as? Bool)!
        
        self.item0 = getValue(status, fieldName: "item0")
        self.item1 = getValue(status, fieldName: "item1")
        self.item2 = getValue(status, fieldName: "item2")
        self.item3 = getValue(status, fieldName: "item3")
        self.item4 = getValue(status, fieldName: "item4")
        self.item5 = getValue(status, fieldName: "item5")
        self.item6 = getValue(status, fieldName: "item6")

    }
}

class PlayerDto {
    var championId: Int
    var summonerId: CLong
    var teamId: Int
    
    init(player: NSDictionary){
        self.championId = (player["championId"] as? Int)!
        self.teamId = (player["teamId"] as? Int)!
        self.summonerId = (player["summonerId"] as? CLong)!
    }
    
}
