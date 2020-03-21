//
//  MatchDto.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/23/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//
import Foundation
import SwiftUI
struct MatchDto: Decodable {
    let metadata : MetadataDto
    let info: InfoDto
    var summmonerInfo: ParticipantDto?
    
    
    mutating func getSummonerInfo(_ puuid: String) {
        summmonerInfo = info.participants.first { (participant) -> Bool in
            participant.puuid == puuid
        }
        let array =  self.summmonerInfo?.traits.filter{ $0.tier_current > 0 }
        self.summmonerInfo?.traits = array!
        self.summmonerInfo?.traits.sort(by: { (t1:TraitDto, t2:TraitDto) -> Bool in
            if t1.tier_current == t1.tier_total {
                return true
            }
            else if t2.tier_current == t2.tier_total {
                return false
            }
            else if t1.tier_current == 2 && t1.tier_total == 3{
                return true
            }
            else if t2.tier_current == 2 && t2.tier_total == 3 {
                return false
            }
        
            return false
        })

    }
    
    
    
    func getPlacement() -> String {
        guard let placement = summmonerInfo?.placement else {return "" }
        switch placement {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(placement)th"
        }
    }
    
    func getMatchColor() -> Color {
        guard let placement = summmonerInfo?.placement else {return Color.red }
        return placement > 4 ? Color.red : Color.green
    }
}

