//
//  LeagueEntryDto.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 3/9/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import Foundation
struct LeagueEntryDto : Decodable {
    let queueType: String
    let rank: String
    let tier: String
    let leaguePoints: Int
    
    func getLeague() -> String {
        switch tier {
        case "provisional":
            return "Unranked"
        case "MASTER", "CHALLENGER", "GRANDMASTER":
            return "\(tier) (\(leaguePoints) LP)"
        default:
            return "\(tier) \(rank) (\(leaguePoints) LP)"
        }
    }
}
