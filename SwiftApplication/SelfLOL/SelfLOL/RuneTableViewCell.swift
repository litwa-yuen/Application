//
//  RuneTableViewCell.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 11/26/15.
//  Copyright © 2015 lit.wa.yuen. All rights reserved.
//

import UIKit

class RuneTableViewCell: UITableViewCell {

    @IBOutlet weak var runeLabel: UILabel!
    @IBOutlet weak var runeImageView: UIImageView!
    var rune: Rune? {
        didSet{
            updateUI()
        }
    }
    
    func updateUI() {
        runeImageView.image = nil
        runeLabel.text = nil
        
        if let rune = self.rune {
            
            if let runeData = map[rune.runeId] {
                runeImageView.image = resizeImage(UIImage(named: runeData.imageId)!, newWidth: 40)
                runeLabel.text = retrieveRune(runeData, runeCounter: rune.count)

            }
            else {
                runeImageView.image = resizeImage(UIImage(named: "unknown")!, newWidth: 40)
                runeLabel.text = "unknown X \(rune.count)"
            }
            runeLabel.font = UIFont(name: "Helvetica", size: 15)
        }
    }
        
    func retrieveRune(rune: JsonRune, runeCounter: Int) -> String {
        var runeDescription = rune.description
        let runeData1 = rune.data1
        let runeData2 = rune.data2
        runeDescription = runeDescription.stringByReplacingOccurrencesOfString("*", withString: String(runeData1))
        runeDescription = runeDescription.stringByReplacingOccurrencesOfString("#", withString: String(runeData2))
        return runeDescription + " X \(runeCounter)"
    }

}
