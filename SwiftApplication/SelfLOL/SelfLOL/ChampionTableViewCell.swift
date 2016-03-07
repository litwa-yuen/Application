import UIKit

class ChampionTableViewCell: UITableViewCell {

    struct TableCellProperties {
        static let CellBoldFont = UIFont(name: "Helvetica-Bold", size: 16)
        static let CellFont = UIFont(name: "Helvetica", size: 15)
    }

    var champion: ChampionStatus? {
        didSet{
            adjustViewLayout(UIScreen.mainScreen().bounds.size)
            aroundBorder(championImageView)
            updateUI()
        }
    }

    @IBOutlet weak var championImageView: UIImageView!
    @IBOutlet weak var championNameLabel: UILabel!
    @IBOutlet weak var championKDA: UILabel!
    @IBOutlet weak var winRateLabel: UILabel!
    @IBOutlet weak var csLabel: UILabel!
    @IBOutlet weak var KDRatioLabel: UILabel!
    @IBOutlet weak var timesOfWinLoss: UILabel!
    @IBOutlet weak var hideView: UIView!
    
    func updateUI() {
        
        if let champion = self.champion {
            championImageView?.image = resizeImage(champion.image!, newWidth: 50)

            championNameLabel.font = TableCellProperties.CellBoldFont
            championNameLabel?.text = "\((champion.name)!)"
            
            csLabel.font = TableCellProperties.CellFont
            csLabel.text = "\((champion.aggregatedStatsDto?.getCS())!) CS"

            KDRatioLabel.font = TableCellProperties.CellBoldFont
            KDRatioLabel.text = "\((champion.aggregatedStatsDto?.calculateKDA())!) KDA"

            championKDA.font = TableCellProperties.CellFont
            championKDA?.text = "\((champion.aggregatedStatsDto?.getAverageKDA())!)"
            
            winRateLabel.font = TableCellProperties.CellBoldFont
            winRateLabel.text = "\((champion.aggregatedStatsDto?.getWinRatePercent())!)"
            
            timesOfWinLoss.font = TableCellProperties.CellFont
            timesOfWinLoss.text = "\((champion.aggregatedStatsDto?.getTimesOfWL())!)"
        }
    }
    
    
    func adjustViewLayout(size: CGSize) {
        
        switch(size.width, size.height) {
        case (480, 320), (568, 320):                        // iPhone 4S, 5s in landscape
            hideView.hidden = false
            
        case (320, 480), (320, 568):                        // iPhone 4S in portrait
            hideView.hidden = true
        default:
            break
        }
    }


}
