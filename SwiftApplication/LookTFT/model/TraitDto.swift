//
//  TraitDto.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/23/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import Foundation
struct TraitDto: Decodable {
    let tier_total: Int
    let name: String
    let tier_current: Int
    let num_units: Int
}
