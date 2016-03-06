
import UIKit

class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet weak var spell2Image: UIImageView!
    @IBOutlet weak var spell1Image: UIImageView!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var championImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var summorName: UILabel!
    @IBOutlet weak var runeButton: UIButton!
    
    struct TableCellProperties {
        static let CellBoldFont = UIFont(name: "Helvetica-Bold", size: 16)
        static let CellFont = UIFont(name: "Helvetica", size: 15)
    }

    var participant: CurrentGameParticipant? {
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        
        if let participant = self.participant {
            if let participantChampion = championsMap[participant.championId] {
                let image = UIImage(named: participantChampion)
                championImageView?.image = resizeImage(image!, newWidth: 50)

            }
            else {
                let image = UIImage(named: "unknown")
                championImageView?.image = resizeImage(image!, newWidth: 50)
            }
            
            summorName?.text = "\(participant.summonerName)"
            summorName.font = TableCellProperties.CellBoldFont
            
            if let spell1 = summonerSpellMap[participant.spell1Id] {
                spell1Image.image = resizeImage(UIImage(named: spell1)!, newWidth: 25)
            }
            else {
                spell1Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
            }
            if let spell2 = summonerSpellMap[participant.spell2Id] {
                spell2Image.image = resizeImage(UIImage(named: spell2)!, newWidth: 25)
            }
            else {
                spell2Image.image = resizeImage(UIImage(named: "unknown")!, newWidth: 25)
            }

            if let rankinfo = self.participant?.rankInfo {
                rankLabel?.text = "\(rankinfo.getRankWithLP())"
                rankLabel.font = TableCellProperties.CellFont
            }
            
            if let rankimage = self.participant?.rankInfo?.image {
                rankImageView?.image = resizeImage(rankimage, newWidth: 50)
            }
        }
    }

}
