//
//  RecentGameTableViewCell.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 1/18/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import UIKit

class RecentGameTableViewCell: UITableViewCell {

    @IBOutlet weak var championImage: UIImageView!
    @IBOutlet weak var spell1Image: UIImageView!
    @IBOutlet weak var spell2Image: UIImageView!
    @IBOutlet weak var KDALabel: UILabel!
    @IBOutlet weak var item6Image: UIImageView!
    @IBOutlet weak var item0Image: UIImageView!
    @IBOutlet weak var item1Image: UIImageView!
    @IBOutlet weak var item2Image: UIImageView!
    @IBOutlet weak var item3Image: UIImageView!
    @IBOutlet weak var item4Image: UIImageView!
    @IBOutlet weak var item5Image: UIImageView!
    @IBOutlet weak var space1View: UIView!
    @IBOutlet weak var space2View: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    
  
    var game: GameDto? {
        didSet{
            updateUI()
        }
    }
    
    func updateUI() {
        
        if let game = self.game {
            if game.stats?.win == true {
                space1View.backgroundColor = UIColor.greenColor()
                space2View.backgroundColor = UIColor.greenColor()
            }
            else {
                space1View.backgroundColor = UIColor.redColor()
                space2View.backgroundColor = UIColor.redColor()
            }
            if let champion = championsMap[game.championId] {
                let image = UIImage(named: champion)
                championImage?.image = resizeImage(image!, newWidth: 50)
            }
            else {
                let image = UIImage(named: "unknown")
                championImage?.image = resizeImage(image!, newWidth: 50)
            }
            if let spell1 = summonerSpellMap[game.spell1] {
                spell1Image.image = resizeImage(UIImage(named: spell1)!, newWidth: 25)
            }
            else {
                spell1Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
            }
            if let spell2 = summonerSpellMap[game.spell2] {
                spell2Image.image = resizeImage(UIImage(named: spell2)!, newWidth: 25)
            }
            else {
                spell2Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
            }
            
            if let item6 = game.stats?.item6?.description {
                if let image = UIImage(named: item6) {
                    item6Image.image = resizeImage(image, newWidth: 25)
                }
                else {
                    item6Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            else {
                item6Image.image = resizeImage(UIImage(named: "empty")!, newWidth: 25)
            }
            
            if let item0 = game.stats?.item0?.description {
                if let image = UIImage(named: item0) {
                    item0Image.image = resizeImage(image, newWidth: 25)
                }
                else {
                    item0Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            else {
                item0Image.image = resizeImage(UIImage(named: "empty")!, newWidth: 25)
            }
            
            if let item1 = game.stats?.item1?.description {
                if let image = UIImage(named: item1) {
                    item1Image.image = resizeImage(image, newWidth: 25)
                }
                else {
                    item1Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            else {
                item1Image.image = resizeImage(UIImage(named: "empty")!, newWidth: 25)
            }
            
            if let item2 = game.stats?.item2?.description {
                if let image = UIImage(named: item2) {
                    item2Image.image = resizeImage(image, newWidth: 25)
                }
                else {
                    item2Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            else {
                item2Image.image = resizeImage(UIImage(named: "empty")!, newWidth: 25)
            }
            
            if let item3 = game.stats?.item3?.description {
                if let image = UIImage(named: item3) {
                    item3Image.image = resizeImage(image, newWidth: 25)
                }
                else {
                    item3Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            else {
                item3Image.image = resizeImage(UIImage(named: "empty")!, newWidth: 25)
            }
            
            if let item4 = game.stats?.item4?.description {
                if let image = UIImage(named: item4) {
                    item4Image.image = resizeImage(image, newWidth: 25)
                }
                else {
                    item4Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            else {
                item4Image.image = resizeImage(UIImage(named: "empty")!, newWidth: 25)
            }
            
            if let item5 = game.stats?.item5?.description {
                if let image = UIImage(named: item5) {
                    item5Image.image = resizeImage(image, newWidth: 25)
                }
                else {
                    item5Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                }
            }
            else {
                item5Image.image = resizeImage(UIImage(named: "empty")!, newWidth: 25)
            }
            
            KDALabel?.text = " \((game.stats?.championsKilled)!)/\((game.stats?.numDeaths)!)/\((game.stats?.assists)!)"
            if game.stats?.win == true {
                resultLabel.text = " WIN"
            }
            else {
                resultLabel.text = " LOSS"
            }
        }
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
