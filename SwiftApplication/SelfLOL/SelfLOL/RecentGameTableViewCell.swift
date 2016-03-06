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
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var timePlayedLabel: UILabel!
    @IBOutlet weak var csLabel: UILabel!
    @IBOutlet weak var ResultView: UIView!
    @IBOutlet weak var gameType: UILabel!
    var isObserving = false

    struct TableCellProperties {
        static let VictoryColor = UIColorFromRGB("00C853")
        static let DefeatColor = UIColorFromRGB("D50000")
        static let CellBoldFont = UIFont(name: "Helvetica-Bold", size: 16)
        static let CellFont = UIFont(name: "Helvetica", size: 14)
        static let CellSmallFont = UIFont(name: "Helvetica", size: 12)
    }
    class var defaultHeight: CGFloat { get{ return 81} }
    class var expandedHeight: CGFloat { get { return 95} }
  
    var game: GameDto? {
        didSet{
            aroundBorder(item0Image)
            aroundBorder(item1Image)
            aroundBorder(item2Image)
            aroundBorder(item3Image)
            aroundBorder(item4Image)
            aroundBorder(item5Image)
            aroundBorder(item6Image)
            updateUI()
        }
    }
    
    func updateUI() {
        adjustViewLayout(UIScreen.mainScreen().bounds.size)
        if let game = self.game {
            gameType.font = TableCellProperties.CellSmallFont
            if game.subType == "RANKED_SOLO_5x5" {
                gameType.text = "Ranked"
            }
            else {
                gameType.text = "Normal"
            }
            resultLabel.font = TableCellProperties.CellBoldFont
            if game.stats?.win == true {
                ResultView.backgroundColor = TableCellProperties.VictoryColor
                resultLabel.text = " Victory"
                resultLabel.textColor = TableCellProperties.VictoryColor
            }
            else {
                resultLabel.text = " Defeat"
                resultLabel.textColor = TableCellProperties.DefeatColor
                ResultView.backgroundColor = TableCellProperties.DefeatColor
                
            }
            
            createTimeLabel.text = timeAgoSince(NSDate(timeIntervalSince1970: (Double)(game.createDate/1000)))
            createTimeLabel.font = TableCellProperties.CellSmallFont
            timePlayedLabel.text = "\(Int((game.stats?.timePlayed)!/60))m \((game.stats?.timePlayed)!%60)s"
            timePlayedLabel.font = TableCellProperties.CellFont
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
                item6Image.image = getEmptyItemImage()
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
                item0Image.image = getEmptyItemImage()
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
                item1Image.image = getEmptyItemImage()
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
                item2Image.image = getEmptyItemImage()
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
                item3Image.image = getEmptyItemImage()

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
                item4Image.image = getEmptyItemImage()

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
                item5Image.image = getEmptyItemImage()
            }
            csLabel.text = "\((game.stats?.minionsKilled)!) CS"
            csLabel.font = TableCellProperties.CellFont
            KDALabel?.text = "\((game.stats?.championsKilled)!) / \((game.stats?.numDeaths)!) / \((game.stats?.assists)!)"
            KDALabel.font = TableCellProperties.CellBoldFont
            
        }
        
    }
    
    func checkHeight() {
        let hiddenSelf: Bool = frame.size.height < RecentGameTableViewCell.expandedHeight
        createTimeLabel.hidden = !hiddenSelf
        timePlayedLabel.hidden = !hiddenSelf
        resultLabel.hidden = !hiddenSelf
        championImage.hidden = !hiddenSelf
        spell1Image.hidden = !hiddenSelf
        spell2Image.hidden = !hiddenSelf
        item0Image.hidden = !hiddenSelf
        item1Image.hidden = !hiddenSelf
        item2Image.hidden = !hiddenSelf
        item3Image.hidden = !hiddenSelf
        item4Image.hidden = !hiddenSelf
        item5Image.hidden = !hiddenSelf
        item6Image.hidden = !hiddenSelf
        KDALabel.hidden = !hiddenSelf
        space1View.hidden = !hiddenSelf
        space2View.hidden = !hiddenSelf
    }
    
    func watchFrameChanges(){
        if !isObserving {
            addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Initial], context: nil)
            isObserving = true
        }
    }
    
    func ignoreFrameChanges() {
        if isObserving {
            removeObserver(self, forKeyPath: "frame")
            isObserving = false
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    
    func adjustViewLayout(size: CGSize) {
        
        switch(size.width, size.height) {
        case (480, 320), (568, 320):                        // iPhone 4S, 5s in landscape
            item0Image.hidden = false
            item1Image.hidden = false
            item2Image.hidden = false
            item3Image.hidden = false
            item4Image.hidden = false
            item5Image.hidden = false
            item6Image.hidden = false
            space1View.hidden = false
            space2View.hidden = false
            
        case (320, 480), (320, 568):                        // iPhone 4S in portrait
            item0Image.hidden = true
            item0Image.hidden = true
            item1Image.hidden = true
            item2Image.hidden = true
            item3Image.hidden = true
            item4Image.hidden = true
            item5Image.hidden = true
            item6Image.hidden = true
            space1View.hidden = true
            space2View.hidden = true
        default:
            break
        }
    }
    
    

}
