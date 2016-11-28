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
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var timePlayedLabel: UILabel!
    @IBOutlet weak var csLabel: UILabel!
    @IBOutlet weak var ResultView: UIView!
    @IBOutlet weak var itemStackView: UIStackView!
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
            aroundBorder(championImage)
            aroundBorder(spell2Image)
            aroundBorder(spell1Image)
            updateUI()
        }
    }
    
    
    func updateUI() {
        adjustViewLayout(UIScreen.main.bounds.size)
        if let game = self.game {
            gameType.font = TableCellProperties.CellSmallFont
            
            if game.subType.contains("ARAM") {
                gameType.text = "ARAM"
            }
            else if game.subType.contains("BOT") {
                gameType.text = "BOT"
            }
            else if game.subType.contains("RANK") {
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
            
            createTimeLabel.text = timeAgoSince(Date(timeIntervalSince1970: (Double)(game.createDate.int64Value/1000)))
            createTimeLabel.font = TableCellProperties.CellSmallFont
            timePlayedLabel.text = "\(Int((game.stats?.timePlayed)!/60))m \((game.stats?.timePlayed)!%60)s"
            timePlayedLabel.font = TableCellProperties.CellFont
            if let champion = championsMap[game.championId] {
                championImage?.image =  UIImage(named: champion)
            }
            else {
                championImage?.image = UIImage(named: "unknown")
            }
            if let spell1 = summonerSpellMap[game.spell1] {
                spell1Image.image = UIImage(named: spell1)
            }
            else {
                spell1Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
            }
            if let spell2 = summonerSpellMap[game.spell2] {
                spell2Image.image = UIImage(named: spell2)
            }
            else {
                spell2Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
                
            }
            
            if let item6 = game.stats?.item6?.description {
                if let image = UIImage(named: item6) {
                    item6Image.image = image
                    
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
                    item0Image.image = image
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
                    item1Image.image = image
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
                    item2Image.image = image
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
                    item3Image.image = image
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
                    item4Image.image = image
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
                    item5Image.image = image
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
        createTimeLabel.isHidden = !hiddenSelf
        timePlayedLabel.isHidden = !hiddenSelf
        resultLabel.isHidden = !hiddenSelf
        championImage.isHidden = !hiddenSelf
        spell1Image.isHidden = !hiddenSelf
        spell2Image.isHidden = !hiddenSelf
        item0Image.isHidden = !hiddenSelf
        item1Image.isHidden = !hiddenSelf
        item2Image.isHidden = !hiddenSelf
        item3Image.isHidden = !hiddenSelf
        item4Image.isHidden = !hiddenSelf
        item5Image.isHidden = !hiddenSelf
        item6Image.isHidden = !hiddenSelf
        KDALabel.isHidden = !hiddenSelf
    }
    
    func watchFrameChanges(){
        if !isObserving {
            addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial], context: nil)
            isObserving = true
        }
    }
    
    func ignoreFrameChanges() {
        if isObserving {
            removeObserver(self, forKeyPath: "frame")
            isObserving = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    
    func adjustViewLayout(_ size: CGSize) {
        
        switch(size.width, size.height) {
        case (480, 320), (568, 320):                        // iPhone 4S, 5s in landscape
            itemStackView.isHidden = true
        case (320, 480), (320, 568):                        // iPhone 4S in portrait
            itemStackView.isHidden = true
        default:
            break
        }
    }
    
    
    
}
