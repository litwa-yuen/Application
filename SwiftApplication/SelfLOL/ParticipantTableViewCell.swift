
import UIKit

class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var championImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var summorName: UILabel!
    var participant: CurrentGameParticipant? {
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        championImageView?.image = nil
        summorName?.text = nil
        
        if let participant = self.participant {
            if let image = UIImage(named: championsMap[participant.championId]!) {
                championImageView?.image = resizeImage(image, newWidth: 50)
            }
            
            summorName?.text = "\(participant.summonerName)"

            if let rankinfo = self.participant?.rankInfo {
                rankLabel?.text = "\(rankinfo.getRankWithLP())"
            }
            
            if let rankimage = self.participant?.rankInfo?.image {
                rankImageView?.image = resizeImage(rankimage, newWidth: 50)
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