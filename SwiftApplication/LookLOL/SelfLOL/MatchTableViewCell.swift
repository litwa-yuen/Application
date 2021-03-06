//
//  MatchTableViewCell.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 2/28/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell, DamageViewDataSource {
    
    @IBOutlet weak var championImageView: UIImageView!
    @IBOutlet weak var spell1ImageView: UIImageView!
    @IBOutlet weak var spell2ImageView: UIImageView!
    @IBOutlet weak var summonerNameLabel: UILabel!
    @IBOutlet weak var item0Image: UIImageView!
    @IBOutlet weak var item1Image: UIImageView!
    @IBOutlet weak var item2Image: UIImageView!
    @IBOutlet weak var item3Image: UIImageView!
    @IBOutlet weak var item4Image: UIImageView!
    @IBOutlet weak var item5Image: UIImageView!
    @IBOutlet weak var item6Image: UIImageView!
    @IBOutlet weak var CSLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var ResultView: UIView!
    @IBOutlet weak var KDALabel: UILabel!
    @IBOutlet weak var damageView: DamageView!{
        didSet{
            damageView.dataSource = self
        }
    }
    var damage: CGFloat = 0.5 {
        didSet {
            damage = min(max(damage,0), 1)
            updateDamageUI()
        }
    }
    
    var damageLabel: String = "0"
    
    struct TableCellProperties {
        static let CellBoldFont = UIFont(name: "Helvetica-Bold", size: 15)
        static let CellFont = UIFont(name: "Helvetica", size: 15)
        static let CellSmallFont = UIFont(name: "Helvetica", size: 12)
        static let VictoryColor = UIColorFromRGB("00C853")
        static let DefeatColor = UIColorFromRGB("D50000")
    }
    
    var maxDamage: CLong = 1

    var participant: Participant? {
        didSet{
            aroundBorder(item0Image)
            aroundBorder(item1Image)
            aroundBorder(item2Image)
            aroundBorder(item3Image)
            aroundBorder(item4Image)
            aroundBorder(item5Image)
            aroundBorder(item6Image)
            aroundBorder(championImageView)
            aroundBorder(spell1ImageView)
            aroundBorder(spell2ImageView)
            updateUI()
        }
    }

    func updateUI() {
        adjustViewLayout(UIScreen.main.bounds.size)
        if let participant = self.participant {
            if let champion = championsMap[participant.championId] {
                championImageView?.image = UIImage(named: champion)
            }
            else {
                championImageView?.image = UIImage(named: "unknown")
            }
            if let spell1 = summonerSpellMap[participant.spell1Id] {
                spell1ImageView.image = UIImage(named: spell1)
            }
            else {
                spell1ImageView.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
            }
            if let spell2 = summonerSpellMap[participant.spell2Id] {
                spell2ImageView.image = UIImage(named: spell2)
            }
            else {
                spell2ImageView.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                
            }
            if let item6 = participant.participantStats.item6?.description {
                if let image = UIImage(named: item6) {
                    item6Image.image = image
                }
                else if item6 == "0" {
                    item6Image.image = getEmptyItemImage()
                }
                else {
                    item6Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            
            if let item0 = participant.participantStats.item0?.description {
                if let image = UIImage(named: item0) {
                    item0Image.image = image
                }
                else if item0 == "0" {
                    item0Image.image = getEmptyItemImage()
                }

                else {
                    item0Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            
            if let item1 = participant.participantStats.item1?.description {
                if let image = UIImage(named: item1) {
                    item1Image.image = image
                }
                else if item1 == "0" {
                    item1Image.image = getEmptyItemImage()
                }
                else {
                    item1Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            
            if let item2 = participant.participantStats.item2?.description {
                if let image = UIImage(named: item2) {
                    item2Image.image = image
                }
                else if item2 == "0" {
                    item2Image.image = getEmptyItemImage()
                }
                else {
                    item2Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            
            if let item3 = participant.participantStats.item3?.description {
                if let image = UIImage(named: item3) {
                    item3Image.image = image
                }
                else if item3 == "0" {
                    item3Image.image = getEmptyItemImage()
                }
                else {
                    item3Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            
            if let item4 = participant.participantStats.item4?.description {
                if let image = UIImage(named: item4) {
                    item4Image.image = image
                }
                else if item4 == "0" {
                    item4Image.image = getEmptyItemImage()
                }
                else {
                    item4Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            
            
            if let item5 = participant.participantStats.item5?.description {
                if let image = UIImage(named: item5) {
                    item5Image.image = image
                }
                else if item5 == "0" {
                    item5Image.image = getEmptyItemImage()
                }
                else {
                    item5Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            damageLabel = "\(participant.participantStats.totalDamageDealtToChampions)"
            damage = CGFloat(Double(participant.participantStats.totalDamageDealtToChampions) / Double(maxDamage))
            summonerNameLabel.text = participant.summonerName
            summonerNameLabel.font = TableCellProperties.CellBoldFont
            KDALabel.text = "\(participant.participantStats.championsKilled) / \(participant.participantStats.numDeaths) / \(participant.participantStats.assists)"
            KDALabel.font = TableCellProperties.CellFont
            CSLabel.text = "\(participant.participantStats.minionsKilled) CS"
            CSLabel.font = TableCellProperties.CellSmallFont
            goldLabel.text = "\(roundToOneDecimal(Double(participant.participantStats.goldEarned),dec: 1000))k gold"
            goldLabel.font = TableCellProperties.CellSmallFont
            if participant.participantStats.win == true {
                ResultView.backgroundColor = TableCellProperties.VictoryColor
            }
            else {
                ResultView.backgroundColor = TableCellProperties.DefeatColor
            }
            
        }
    }
    
    func updateDamageUI() {
        damageView.setNeedsDisplay()
    }
    
    func damagePercentForDamageView(_ sender: DamageView) -> CGFloat? {
        return damage
    }
    
    func damageForDamageLabel(_ sender: DamageView) -> String? {
        return damageLabel
    }
    
    func roundToOneDecimal(_ num: Double, dec: Double) -> Double {
        let result = num/dec
        return NSString(format: "%.01f", result).doubleValue
    }
    
    func adjustViewLayout(_ size: CGSize) {
        
        switch(size.width, size.height) {
        case (480, 320), (568, 320):                        // iPhone 4S, 5s in landscape
            summonerNameLabel.isHidden = true
            
        case (320, 480), (320, 568):                        // iPhone 4S in portrait
            summonerNameLabel.isHidden = true
        default:
            break
        }
    }


}
