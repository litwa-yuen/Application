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
            championImageView?.image = resizeImage(champion.image!, newWidth: 50)
            championKDA?.text = "\((champion.aggregatedStatsDto?.getAverageStatus())!)"
            winRateLabel.text = "\((champion.aggregatedStatsDto?.getWinRate())!)"
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
