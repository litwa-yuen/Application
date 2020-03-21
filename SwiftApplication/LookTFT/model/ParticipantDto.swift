//
//  ParticipantDto.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/23/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import Foundation

struct ParticipantDto: Decodable {
    let companion: CompanionDto
    let placement: Int
    let level: Int
    let puuid: String
    var units: [UnitDto] = []
    var traits: [TraitDto] = []
    
}
