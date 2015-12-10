
import Foundation

class Summoner {
    var id: CLong
    var name: String
    var profileIconId: Int?
    var revisionDate: CLong?
    var summonerLevel: Int?
    var rank: String?
    var rankInfo: RankInfo?
    
    init(data: NSDictionary) {
        self.id = (data["id"] as? CLong)!
        self.name = (data["name"] as? String)!
        if let icon = data["profileIconId"] as? Int {
            self.profileIconId = icon
        }
        
        if let date = data["revisionDate"] as? CLong {
            self.revisionDate = date
        }
        
        if let level = data["summonerLevel"] as? Int {
            self.summonerLevel = level
        }
        
    }
    
  
}
