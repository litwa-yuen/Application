
import Foundation

var currentGame: CurrentGameInfo? = nil
var map = [CLong:JsonRune]()
var region = "na"
class CurrentGameInfo {
    var gameId: CLong
    var bannedChampions: [BannedChampion]?
    var participants: [CurrentGameParticipant]?
    var table:[[CurrentGameParticipant]]?
    var blueTeamId: CLong?
    
    init(game: NSDictionary) {
        self.gameId = (game["gameId"] as? CLong)!
        if let champions = game["bannedChampions"] as? NSArray {
            self.bannedChampions = []
            for champion in champions {
                self.bannedChampions?.append(BannedChampion(champion: champion as! NSDictionary))
            }
        }
        if let gameParticipants = game["participants"] as? NSArray {
            self.participants = []
            for participant in gameParticipants {
                self.participants?.append(CurrentGameParticipant(participant: participant as! NSDictionary))
            }
        }
    }
    
    func split() {
        participants?.sortInPlace({ (p1:CurrentGameParticipant, p2:CurrentGameParticipant) -> Bool in
            return p1.teamId < p2.teamId
        })
        
        var blueTeam: [CurrentGameParticipant] = []
        var purpleTeam: [CurrentGameParticipant] = []
        table = []
        blueTeamId = participants?.first?.teamId
        for participant in participants! {
            if participant.teamId == blueTeamId! {
                blueTeam.append(participant)
            }
            else {
                purpleTeam.append(participant)
            }
        }
        table?.append(blueTeam)
        table?.append(purpleTeam)
        
        
    }
    
}

class BannedChampion {
    var championId: CLong
    var pickTurn: Int
    var teamId: CLong
    init(champion: NSDictionary) {
        self.championId = (champion["championId"] as? CLong)!
        self.pickTurn = (champion["pickTurn"] as? Int)!
        self.teamId = (champion["teamId"] as? CLong)!
        
    }
}

class CurrentGameParticipant {
    
    var championId: CLong
    var teamId: Int
    var spell1Id: CLong
    var spell2Id: CLong
    var summonerId: CLong
    var summonerName: String
    var masteries: [Mastery]?
    var runes: [Rune]?
    var rankInfo: RankInfo?
    
    init(participant: NSDictionary){
        self.championId = (participant["championId"] as? CLong)!
        self.teamId = (participant["teamId"] as? CLong)!
        self.spell1Id = (participant["spell1Id"] as? CLong)!
        self.spell2Id = (participant["spell2Id"] as? CLong)!
        self.summonerId = (participant["summonerId"] as? CLong)!
        self.summonerName = (participant["summonerName"] as? String)!
        
        if let participantMasteries = participant["masteries"] as? NSArray {
            self.masteries = []
            for mastery in participantMasteries {
                self.masteries?.append(Mastery(mastery: mastery as! NSDictionary))
            }
        }
        
        if let participantRunes = participant["runes"] as? NSArray {
            self.runes = []
            for rune in participantRunes {
                self.runes?.append(Rune(rune: rune as! NSDictionary))
            }
        }
    }
    
}

class Mastery {
    var masteryId: CLong
    var rank: Int
    init(mastery: NSDictionary) {
        self.masteryId = (mastery["masteryId"] as? CLong)!
        self.rank = (mastery["rank"] as? Int)!
    }
}

class Rune {
    var count: Int
    var runeId: CLong
    init(rune: NSDictionary) {
        self.count = (rune["count"] as? Int)!
        self.runeId = (rune["runeId"] as? CLong)!
    }
}

class JsonRune {
    var description: String
    var runeId: CLong
    var imageId: String
    var data1: Double
    var data2: Double
    init(rune: NSDictionary) {
        self.description = (rune["description"] as? String)!
        self.runeId = (rune["runeId"] as? CLong)!
        self.data2 = (rune["data2"] as? Double)!
        self.data1 = (rune["data1"] as? Double)!
        self.imageId = (rune["imageId"] as? String)!
    }
}