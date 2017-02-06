//
//  championMasteryTableViewCell.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 5/18/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import UIKit

class ChampionMasteryTableViewCell: UITableViewCell {

    @IBOutlet weak var championScoreLabel: UILabel!
    @IBOutlet weak var championImage: UIImageView!
    @IBOutlet weak var championLevelLabel: UILabel!
    @IBOutlet weak var championNameLabel: UILabel!

    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var levelImage: UIImageView!
    var mastery: ChampionMasteryDTO? {
        didSet{
            aroundBorder(championImage)
            adjustViewLayout(UIScreen.main.bounds.size)
            updateUI()
        }
    }
    
    struct TableCellProperties {
        static let CellBoldFont = UIFont(name: "Helvetica-Bold", size: 16)
        static let CellFont = UIFont(name: "Helvetica", size: 15)
    }
    
    func updateUI() {
        
        if let mastery = self.mastery {
            championImage?.image = mastery.image
            
            levelImage.image = mastery.levelImage
            
            championNameLabel.font = TableCellProperties.CellBoldFont
            championNameLabel?.text = "\(mastery.name)"
            
            championLevelLabel.font = TableCellProperties.CellFont
            championLevelLabel.text = "Level \(mastery.championLevel)"
            
            championScoreLabel.font = TableCellProperties.CellBoldFont
            championScoreLabel.text = "\(mastery.championPoints)"
        }
    }
    
    func adjustViewLayout(_ size: CGSize) {
        
        switch(size.width, size.height) {
        case (480, 320), (568, 320):                        // iPhone 4S, 5s in landscape
            hideView.isHidden = false
            
        case (320, 480), (320, 568):                        // iPhone 4S in portrait
            hideView.isHidden = true
        default:
            break
        }
    }
}
