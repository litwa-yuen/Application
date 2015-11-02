//
//  ChampionTableViewCell.swift
//  SelfLOL
//
//  Created by Lit Wa Yuen on 10/31/15.
//  Copyright © 2015 lit.wa.yuen. All rights reserved.
//

import UIKit

class ChampionTableViewCell: UITableViewCell {

    var champion: ChampionStatus? {
        didSet{
            updateUI()
        }
    }

    @IBOutlet weak var championImageView: UIImageView!
    @IBOutlet weak var championNameLabel: UILabel!
    @IBOutlet weak var championKDA: UILabel!
    @IBOutlet weak var winRateLabel: UILabel!
    
    func updateUI() {
        championKDA?.attributedText = nil
        championNameLabel?.text = nil
        championImageView?.image = nil
        winRateLabel?.attributedText = nil
        
        if let champion = self.champion {
            championNameLabel?.text = "\((champion.name)!) "
            championImageView?.image = champion.image
            let totalSessionsPlayed = Double((champion.aggregatedStatsDto?.totalSessionsPlayed)!)
            let totalSessionsWon =  Double((champion.aggregatedStatsDto?.totalSessionsWon)!)
            let totalChampionKills = Double((champion.aggregatedStatsDto?.totalChampionKills)!)
            let totalDeathsPerSession = Double((champion.aggregatedStatsDto?.totalDeathsPerSession)!)
            let totalAssists = Double((champion.aggregatedStatsDto?.totalAssists)!)
            championKDA?.text = "\(roundToOneDecimal(totalChampionKills, dec: totalSessionsPlayed))/\(roundToOneDecimal(totalDeathsPerSession, dec: totalSessionsPlayed))/\(roundToOneDecimal(totalAssists, dec: totalSessionsPlayed))"
            winRateLabel.text = "\(roundToPercent(totalSessionsWon, dec: totalSessionsPlayed))% \(Int(totalSessionsPlayed)) Played"
        }
    }
    
    func roundToOneDecimal(num: Double, dec: Double) -> Double {
        let result = num/dec
        return NSString(format: "%.01f", result).doubleValue
    }
    
    func roundToPercent(num: Double, dec: Double) -> Int {
        let result = num/dec * 100
        return Int(result)
    }

}
