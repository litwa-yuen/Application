import UIKit

class CurrentGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var participantTableView: UITableView!
    var summoner: Summoner? {
        willSet{
            indicator.startAnimating()
            if newValue?.id != summoner?.id {
                if CheckReachability.isConnectedToNetwork() {
                    fetchCurrentGame((newValue?.id)!)
                }
                else {
                    showReponseMessage("Network Unavailable.")
                }
            }
        }
    }
    var game: CurrentGameInfo? {
        didSet{
            game?.split()
            participantTableView.reloadData()
            if game != nil && currentGame?.gameId != game?.gameId {
                for participant in (game?.participants)! {
                    fetchRankInfo(participant)
                }
                currentGame = self.game
            }
            else {
                indicator.stopAnimating()
            }
        }
    }
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        participantTableView.estimatedRowHeight = participantTableView.rowHeight
        participantTableView.rowHeight = UITableViewAutomaticDimension
        participantTableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Storyboard.ReuseFooterIdentifier)
        indicator.center = view.center
        view.addSubview(indicator)
    }
        
    // MARK: - UITableViewDataSource
    private struct Storyboard {
        static let ReuseCellIdentifier = "participant"
        static let ReuseFooterIdentifier = "banned"
        static let DetailIdentifier = "detail"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        guard let section = game?.table?.count else { return 0 }
        return section
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let counter = game?.table![section].count
            else {
                return 0
        }
        return counter
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! ParticipantTableViewCell
    
        cell.participant = game?.table![indexPath.section][indexPath.row]
        cell.runeButton.tag = indexPath.row
        cell.runeButton.addTarget(self, action: "checkRune:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let team = game?.table![section].first
        if team?.teamId == game!.blueTeamId {
            return "Blue Team"
        }
        else {
            return "Purple Team"
        }
    }
    
    @IBAction func checkRune(sender: UIButton) {
        let butttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView: self.participantTableView)
        if let indexPath:NSIndexPath = self.participantTableView.indexPathForRowAtPoint(butttonPosition) {
            let participant:CurrentGameParticipant = (game?.table![indexPath.section][indexPath.row])!
            let tvc = self.storyboard?.instantiateViewControllerWithIdentifier("RunesViewController") as? RunesViewController
            tvc?.runes = participant.runes
            tvc?.title = "\(participant.summonerName)'s Rune"
            self.navigationController?.pushViewController(tvc!, animated: true)

        }
       
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if game?.bannedChampions?.count > 0 {
            return 50
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let team = game?.table![section].first
        var champs:[String] = []
        if let bannedChampions = game?.bannedChampions {
            for champion in bannedChampions {
                if champion.teamId == team?.teamId {
                    if let bannedChampion = championsMap[champion.championId] {
                        champs.append(bannedChampion)
                    }
                    else {
                        champs.append("unknown")
                    }
                }
            }
        }
        if champs.count > 0 {
            let h = tableView
                .dequeueReusableHeaderFooterViewWithIdentifier(Storyboard.ReuseFooterIdentifier)!
            h.backgroundView = UIView()
            h.backgroundView?.backgroundColor = UIColor.blackColor()
            let lab = UILabel()
            lab.font = UIFont(name:"Helvetica-Bold", size:12)
            lab.textColor = UIColorFromRGB("D50000")
            lab.text = "Ban:"
            lab.backgroundColor = UIColor.clearColor()
            h.contentView.addSubview(lab)
            let champ1 = UIImageView()
            champ1.image = UIImage(named:champs[0])
            h.contentView.addSubview(champ1)
            let champ2 = UIImageView()
            if champs.count >= 2  {
                champ2.image = UIImage(named: champs[1])
            }
            h.contentView.addSubview(champ2)
            let champ3 = UIImageView()
            if champs.count >= 3 {
                champ3.image = UIImage(named: champs[2])
            }
            h.contentView.addSubview(champ3)
            lab.translatesAutoresizingMaskIntoConstraints = false
            champ1.translatesAutoresizingMaskIntoConstraints = false
            champ2.translatesAutoresizingMaskIntoConstraints = false
            champ3.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:[lab(30)]-10-[champ3(50)]-5-[champ2(50)]-5-[champ1(50)]-5-|",
                    options:[], metrics:nil, views:["champ1":champ1, "lab":lab, "champ2":champ2, "champ3":champ3]),
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[champ1]|", options:[], metrics:nil, views:["champ1":champ1]),
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[champ2]|", options:[], metrics:nil, views:["champ2": champ2]),
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[champ3]|", options:[], metrics:nil, views:["champ3": champ3]),
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[lab]|", options:[], metrics:nil, views:["lab":lab])
                ].flatten().map{$0})
            
            return h
            
        }
        else {
            return nil
        }
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.DetailIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = participantTableView.indexPathForCell(cell!) {
                    let seguedToDetail = segue.destinationViewController as? LOLSelfViewController
                    let participant = (game?.table![indexPath.section][indexPath.row])! as CurrentGameParticipant
                    let obj:NSDictionary = ["name":participant.summonerName, "id":participant.summonerId]
                    seguedToDetail?.summoner = Summoner(data: obj)
                    seguedToDetail?.summonerName = participant.summonerName
                    self.participantTableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            default: break
            }
        }
    }
    
    func fetchRankInfo(participant: CurrentGameParticipant){
        if participant.summonerId == (summoner?.id)! {
            if summoner?.rankInfo != nil {
                participant.rankInfo = summoner!.rankInfo
                return
            }
        }
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v2.5/league/by-summoner/\(participant.summonerId)/entry?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! NSHTTPURLResponse? {
                            self.indicator.stopAnimating()
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    if let entries = resultDict["\(participant.summonerId)"] as? NSArray {
                                        participant.rankInfo = RankInfo(data: entries[0] as! NSDictionary)
                                        self.participantTableView.reloadData()
                                    }
                                }
                            case 404:
                                let obj:NSDictionary = ["name":participant.summonerName, "tier":"provisional", "queue":"SOLO_RANK5X5"]
                                participant.rankInfo = RankInfo(data: obj)
                                self.participantTableView.reloadData()
                            case 429:
                                self.showReponseMessage("Rate Limit Exceeded.")
                            case 503, 500:
                                self.showReponseMessage( "Service Unavailable.")
                            default:
                                self.showReponseMessage("Wait for Update.")

                                
                            }
                        }
                        
                    } catch {}
                }
            })
        }
        task.resume()
    }
    
    
    func fetchCurrentGame(summonerId: CLong) {
        
        let url = NSURL(string: "https://\(region).api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/\(region.uppercaseString)1/\(summonerId)?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! NSHTTPURLResponse? {
                            self.indicator.stopAnimating()
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    self.game = CurrentGameInfo(game: resultDict)
                                    if self.game?.gameId == currentGame?.gameId {
                                        self.game = currentGame
                                    }
                                }
                            case 404:
                                self.showReponseMessage("Not in a game.")
                            case 429:
                                self.showReponseMessage("Rate Limit Exceeded.")
                            case 503, 500:
                                self.showReponseMessage("Service Unavailable.")
                            default:
                                self.showReponseMessage("Wait for Update.")
                            }
                        }
                        
                    } catch {}
                }
            })
        }
        task.resume()
    }
    
    
    func showReponseMessage(message: String) {
        indicator.stopAnimating()
        let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        self.participantTableView.backgroundView = messageLabel
        self.participantTableView.separatorStyle = .None
        if game != nil {
            game = nil
        }
        participantTableView.reloadData()
    }
}
