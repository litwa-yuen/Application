//
//  ChampionBansTableViewCell.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 9/10/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import UIKit

class ChampionBansTableViewCell: UITableViewCell {

    @IBOutlet weak var champImageView: UIImageView!
    @IBOutlet weak var banRankLabel: UILabel!
    var champ: BannedChampion? {
        didSet{
            aroundBorder(champImageView)
            updateUI()
        }
    }
    
    func updateUI() {
        champImageView.image = nil
        banRankLabel.text = nil
        
        if let champ = self.champ {
            
            if let champData = championsMap[champ.championId] {
                champImageView.image = UIImage(named: champData)
            }
            else {
                champImageView.image = UIImage(named: "unknown")
            }
            var sub = ""
            switch champ.pickTurn {
            case 1:
                sub = "st ban"
            case 2:
                sub = "nd ban"
            case 3:
                sub = "rd ban"
            default:
                sub = "th ban"
            }
            banRankLabel.text = "\(champ.pickTurn.description)\(sub)"
            banRankLabel.font = UIFont(name: "Helvetica", size: 15)
        }
    }

}
