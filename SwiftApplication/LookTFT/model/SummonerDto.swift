//
//  SummonerDto.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/23/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//
import Foundation

struct SummonerDto : Identifiable, Decodable {
    let name: String
    let puuid: String
    let id: String
    let accountId: String
    var region: String?
}
