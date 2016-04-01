
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
        self.profileIconId = getValue(data, fieldName: "profileIconId")
        self.revisionDate = getValue(data, fieldName: "revisionDate")
        self.summonerLevel = getValue(data, fieldName: "summonerLevel")
        
    }
    
  
}
