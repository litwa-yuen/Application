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

}
