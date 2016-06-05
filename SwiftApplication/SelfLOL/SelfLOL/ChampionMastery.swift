//
//  ChampionMastery.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 5/18/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import Foundation
import UIKit

class ChampionMasteryDTO {
    var championId: CLong
    var championLevel: Int
    var championPoints: Int
    var levelImage: UIImage? {
        return UIImage(named: "tier\(championLevel)")
    }
    var name: String
    var image: UIImage? {
        if let championString = championsMap[championId] {
            return UIImage(named: championString)
        }
        else {
            return UIImage(named: "unknown")
        }
    }
    
    init(data: NSDictionary) {
        self.championId = getValue(data, fieldName: "championId")!
        self.championLevel = getValue(data, fieldName: "championLevel")!
        self.championPoints = getValue(data, fieldName: "championPoints")!
        if let championName = championsMap[self.championId] {
            self.name = championName
        }
        else {
            self.name = "unknown"
        }
    }
    
    
}