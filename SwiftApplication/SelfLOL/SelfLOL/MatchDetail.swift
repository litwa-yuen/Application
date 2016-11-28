
import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


var matchDetail: MatchDetail? = nil

class MatchDetail {
    var matchCreation: NSNumber
    var matchDuration: CLong
    var matchId: NSNumber
    var queueType: String
    var participantIdentities: [ParticipantIdentity]?
    var participants: [Participant]?
    var teams: [Team]?
    var table:[[Participant]]?
    var blueTeamId: CLong?
    var maxDamage: CLong?
    
    init(match: NSDictionary) {
        self.matchCreation = (match["matchCreation"] as? NSNumber)!
        self.matchDuration = (match["matchDuration"] as? CLong)!
        self.queueType = (match["queueType"] as? String)!
        self.matchId = (match["matchId"] as? NSNumber)!
        if let teams = match["teams"] as? NSArray {
            self.teams = []
            for team in teams {
                self.teams?.append(Team(team: team as! NSDictionary))
            }
        }
        if let identities = match["participantIdentities"] as? NSArray {
            self.participantIdentities = []
            for identity in identities {
                self.participantIdentities?.append(ParticipantIdentity(identity: identity as! NSDictionary))
            }
        }
        if let gameParticipants = match["participants"] as? NSArray {
            self.participants = []
            for participant in gameParticipants {
                self.participants?.append(Participant(participant: participant as! NSDictionary, identities: participantIdentities!))
            }
        }
    }
    
    func split(_ players: [PlayerDto]) -> Bool {
        participants?.sort(by: { (p1:Participant, p2:Participant) -> Bool in
            return p1.teamId < p2.teamId
        })
        
        var blueTeam: [Participant] = []
        var purpleTeam: [Participant] = []
        table = []
        blueTeamId = participants?.first?.teamId
        
        for player in players {
            if let foundPlayer = findPlayer(player.teamId, championId: player.championId) {
                foundPlayer.summonerId = player.summonerId
            }
        }
        maxDamage = participants?.first?.participantStats.totalDamageDealtToChampions
        for participant in participants! {
            if maxDamage < participant.participantStats.totalDamageDealtToChampions {
                maxDamage = participant.participantStats.totalDamageDealtToChampions
            }
            if participant.spell1Id == 0 {
                continue
            }
            if participant.teamId == blueTeamId! {
                blueTeam.append(participant)
            }
            else {
                purpleTeam.append(participant)
            }
        }
        
        table?.append(blueTeam)
        table?.append(purpleTeam)
        
        return true
    }
    
    func findPlayer(_ teamId:CLong, championId:CLong) -> Participant? {
        for p in participants! {
            if p.championId == championId && p.teamId == teamId {
                return p
            }
        }
        return nil
    }
    
    func getResult() -> String {
        var resultNumber = [(0, 0, 0),(0, 0, 0)]
        for p in participants! {
            var teamIndex: Int
            if p.teamId == blueTeamId {
                teamIndex = 0
            }
            else {
                teamIndex = 1
            }
            resultNumber[teamIndex].0 += p.participantStats.championsKilled
            resultNumber[teamIndex].1 += p.participantStats.numDeaths
            resultNumber[teamIndex].2 += p.participantStats.assists
        }
        return "\(resultNumber[0].0) / \(resultNumber[0].1) / \(resultNumber[0].2) vs \(resultNumber[1].0) / \(resultNumber[1].1) / \(resultNumber[1].2)"
    }
}

class Participant: CurrentGameParticipant {
    var participantId: Int
    var highestAchievedSeasonTier: String?
    var participantStats: ParticipantStats

    init(participant: NSDictionary, identities: [ParticipantIdentity]) {
        self.participantId = (participant["participantId"] as? Int)!
        if let highestTier = participant["highestAchievedSeasonTier"] as? String {
            self.highestAchievedSeasonTier = highestTier
        }
        self.participantStats = ParticipantStats(status: (participant["stats"] as? NSDictionary)!)
        super.init(participant: participant)
        let found: Int = identities.index { (identity) -> Bool in
             return identity.participantId == self.participantId
        }!
        if let name = identities[found].summonerName {
            self.summonerName = name
        }
        if let id = identities[found].summonerId {
            self.summonerId = id
        }
    }
}

class ParticipantIdentity {
    var participantId: Int
    var summonerId: CLong?
    var summonerName: String?
    init(identity: NSDictionary) {
        self.participantId = (identity["participantId"] as? Int)!
        if let dict = identity["player"] as? NSDictionary {
            self.summonerName = (dict["summonerName"] as? String)!
            self.summonerId = (dict["summonerId"] as? CLong)!
        }
    }
}


class PlayerInfo {
    var summonerId: CLong
    var summonerName: String
    
    init(player: NSDictionary) {
        self.summonerId = (player["summonerId"] as? CLong)!
        self.summonerName = (player["summonerName"] as? String)!
    }
}

class ParticipantStats: RawStatsDto {
    var totalDamageDealtToChampions: CLong
    var visionWardsBoughtInGame: CLong
    var sightWardsBoughtInGame: CLong
    override init(status: NSDictionary) {
        self.totalDamageDealtToChampions = (status["totalDamageDealtToChampions"] as? CLong)!
        self.visionWardsBoughtInGame = (status["visionWardsBoughtInGame"] as? CLong)!
        self.sightWardsBoughtInGame = (status["sightWardsBoughtInGame"] as? CLong)!
        super.init(status: status)
    }
}

class Team {
    var baronKills: Int
    var dragonKills: Int
    var teamId: Int
    var riftHeraldKills: Int
    var towerKills: Int
    var winner: Bool
    var bans: [BannedChampion]?
    init(team: NSDictionary) {
        self.baronKills = (team["baronKills"] as? Int)!
        self.dragonKills = (team["dragonKills"] as? Int)!
        self.teamId = (team["teamId"] as? Int)!
        self.riftHeraldKills = team["riftHeraldKills"] as? Int ?? 0
        self.towerKills = (team["towerKills"] as? Int)!
        self.winner = (team["winner"] as? Bool)!
        if let bans = team["bans"] as? NSArray {
            self.bans = []
            for ban in bans {
                let champ = BannedChampion(champion: ban as! NSDictionary)
                champ.teamId = self.teamId
                self.bans?.append(champ)
            }
        }
    }
}
