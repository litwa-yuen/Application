
import UIKit
import Firebase

class TrendingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var trendingTableView: UITableView!
    @IBOutlet weak var updatedDateLabel: UILabel!
    
    let database = FIRDatabase.database()
    var bannedChamps = [BannedChampion]()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var messageLabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.center = view.center
        view.addSubview(indicator)
        trendingTableView.estimatedRowHeight = trendingTableView.rowHeight
        trendingTableView.rowHeight = UITableViewAutomaticDimension
       

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        indicator.startAnimating()
        if CheckReachability.isConnectedToNetwork() {
            let trending = database.reference().child("trending/updatedDate")
            
            trending.observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
                
                self.updatedDateLabel.text = "The Most Banned Champions in \((snapshot.value?.description)!)"
                
            }
            let champs = database.reference().child("trending/banned")
            
            champs.queryOrderedByKey().observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
                
                let champ = snapshot.value!["id"] as! CLong
                let rank = snapshot.value!["rank"] as! Int
                let obj:NSDictionary = ["championId":champ, "pickTurn":rank]
                
                self.bannedChamps.append(BannedChampion(champion: obj))
                self.indicator.stopAnimating()
                self.trendingTableView.reloadData()
                
            }

        }
        else {
            updatedDateLabel.hidden = true
            showReponseMessage("Network Unavailable.")
        }


        
    }
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "ban"
        static let BorderColor = "607D8B"
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bannedChamps.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! ChampionBansTableViewCell
        cell.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).CGColor
        cell.layer.borderWidth = 1.0
        cell.champ = bannedChamps[indexPath.row]
        return cell
    }
    
    func showReponseMessage(message: String) {
        indicator.stopAnimating()
        messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        trendingTableView.hidden = true
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
