//
//  UnitDto.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/23/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import Foundation
struct UnitDto: Decodable {
    let tier: Int
    let items: [Int]
    let character_id: String
    let name: String
    let rarity: Int
}
