
import UIKit
import Firebase

class TrendingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var trendingTableView: UITableView!
    @IBOutlet weak var updatedDateLabel: UILabel!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    let database = FIRDatabase.database()
    var bannedChamps = [BannedChampion]()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var messageLabel = UILabel()
    
    var isMainPage = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.center = view.center
        view.addSubview(indicator)
        trendingTableView.estimatedRowHeight = trendingTableView.rowHeight
        trendingTableView.rowHeight = UITableViewAutomaticDimension
       

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicator.startAnimating()

        if !isMainPage {
            searchButton.tintColor = UIColor.clear;
            searchButton.isEnabled = false
        }
        if CheckReachability.isConnectedToNetwork() {
            
            let trending = database.reference().child("trending/updatedDate")
            
            trending.observe(.value) { (snapshot: FIRDataSnapshot) in
                
                self.updatedDateLabel.text = "Popular Bans on \((snapshot.value as! String))"
                
            }
            let champs = database.reference().child("trending/banned")
            
            champs.queryOrderedByKey().observe(.childAdded) { (snapshot: FIRDataSnapshot) in
                
                let champ = (snapshot.value as? NSDictionary)?["id"] as? CLong ?? 0
                let rank = (snapshot.value as? NSDictionary)?["rank"] as? Int ?? 1
                let obj:NSDictionary = ["championId":champ, "pickTurn":rank]
                
                self.bannedChamps.append(BannedChampion(champion: obj))
                self.indicator.stopAnimating()
                self.trendingTableView.reloadData()
            }

        }
        else {
            updatedDateLabel.isHidden = true
            showReponseMessage("Network Unavailable.")
        }
        
    }
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "ban"
        static let BorderColor = "607D8B"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bannedChamps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as! ChampionBansTableViewCell
        cell.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).cgColor
        cell.layer.borderWidth = 1.0
        cell.champ = bannedChamps[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func showReponseMessage(_ message: String) {
        indicator.stopAnimating()
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.center
        trendingTableView.isHidden = true
        view.addSubview(messageLabel)
    }

    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
