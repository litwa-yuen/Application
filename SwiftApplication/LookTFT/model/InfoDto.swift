//
//  InfoDTo.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/23/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

struct InfoDto: Decodable {
    let game_datetime: CLong
    let game_length: Float
    let participants: [ParticipantDto]
}
