import UIKit

class MatchViewController: UIViewController, UITableViewDataSource {
    
    // MARK: - UI Outlet
    @IBOutlet weak var matchTable: UITableView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var queueTypeLabel: UILabel!
    @IBOutlet weak var playedTimeLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var matchDetailStack: UIStackView!
    
    // MARK: - Properties
    var messageLabel = UILabel()
    var match: MatchDetail? {
        didSet{
            if match?.queueType.containsString("ARAM") == true {
                queueTypeLabel.text = "ARAM"
            }
            else if match?.queueType.containsString("RANK") == true {
                queueTypeLabel.text = "Ranked"
            }
            else if match?.queueType.containsString("BOT") == true {
                queueTypeLabel.text = "BOT"
            }
            else {
                queueTypeLabel.text = "Normal"
            }
            queueTypeLabel.font = Storyboard.CellFont
            timeAgoLabel.text = timeAgoSince(NSDate(timeIntervalSince1970: (Double)((match?.matchCreation.longLongValue)!/1000)))
            timeAgoLabel.font = Storyboard.CellFont
            playedTimeLabel.text = "\(Int((match?.matchDuration)!/60))m \((match?.matchDuration)!%60)s"
            playedTimeLabel.font = Storyboard.CellFont

            match!.split(fellowPlayers)
            resultLabel.text = match?.getResult()
            resultLabel.font = Storyboard.CellBoldFont
            matchDetailStack.hidden = false
            if match != nil && matchDetail?.matchId != match?.matchId {
                for participant in (match?.participants)! {
                    if participant.summonerId == 0 {
                        participant.summonerName = matchInit.2
                        participant.summonerId = matchInit.3
                    }
                    else {
                        fetchRankInfo(participant)
                    }

                }
                matchDetail = self.match
            }
            else {
            }
            matchTable.reloadData()
        }
    }

    var matchId:NSNumber = 0 {
        willSet{
            if newValue != matchDetail?.matchId {
                if CheckReachability.isConnectedToNetwork() {
                    fetchMatchDetail(newValue)
                }
                else {
                    indicator.stopAnimating()
                    showReponseMessage("Network Unavailable.")
                }
            }
        }
    }
    
    var fellowPlayers: [PlayerDto] = []
    
    var searchedSummonerName = String()
    
    var searchedSummonerId = CLong()
    
    var matchInit = ([PlayerDto](),NSNumber(),"",0) {
        didSet {
            fellowPlayers = matchInit.0
            matchId = matchInit.1
            searchedSummonerName = matchInit.2
            searchedSummonerId = matchInit.3
        }
    }

    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    // MARK: - setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchDetailStack.hidden = true

        if matchId != 0 && matchId == matchDetail?.matchId {
            match = matchDetail
        }
        matchTable.estimatedRowHeight = matchTable.rowHeight
        matchTable.rowHeight = UITableViewAutomaticDimension
        indicator.center = view.center
        view.addSubview(indicator)
        matchTable.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    private struct Storyboard {
        static let ReuseCellIdentifier = "player"
        static let SummonerIdentifier = "summoner"
        static let BorderColor = "607D8B"
        static let CellFont = UIFont(name: "Helvetica", size: 15)
        static let CellBoldFont = UIFont(name: "Helvetica-Bold", size: 16)

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return match?.table?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return match?.table![section].count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! MatchTableViewCell
        cell.maxDamage = (match?.maxDamage)!
        cell.participant = match?.table![indexPath.section][indexPath.row]
        cell.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).CGColor
        cell.layer.borderWidth = 1.0
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if match?.table![section].isEmpty == true {
            return nil
        }
        
        let team = match?.teams![section]
        var result  = ""
        if team!.winner == true {
            result = "Victory"
        }
        else {
            result = "Defeat"
        }
        if team!.teamId == match!.blueTeamId {
            
            return "Blue Team \(result)"
        }
        else {
            return "Purple Team \(result)"
        }
        
    }
    
    // MARK: - League of Lengends API
    func fetchMatchDetail(matchId: NSNumber) {
        indicator.startAnimating()
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v2.2/match/\(matchId)?api_key=\(api_key)")
        
        
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! NSHTTPURLResponse? {
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    self.match = MatchDetail(match: resultDict)
                                    self.indicator.stopAnimating()
                                }
                            case 404:
                                self.showReponseMessage("Game Detail not found.")
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

    func fetchRankInfo(participant: Participant){
        indicator.startAnimating()
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.4/summoner/\(participant.summonerId)?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! NSHTTPURLResponse? {
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    if let entries = resultDict["\(participant.summonerId)"] as? NSDictionary {
                                        participant.summonerName = (entries["name"] as? String)!
                                        matchDetail = self.match
                                        self.matchTable.reloadData()
                                        self.indicator.stopAnimating()
                                    }
                                }
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
    
    func showReponseMessage(message: String) {
        messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(messageLabel)
        indicator.stopAnimating()
        messageLabel.hidden = false
    }

    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SummonerIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = matchTable.indexPathForCell(cell!) {
                    let seguedToDetail = segue.destinationViewController as? LOLSelfViewController
                    let participant = (match?.table![indexPath.section][indexPath.row])! as CurrentGameParticipant
                    let obj:NSDictionary = ["name":participant.summonerName, "id":participant.summonerId]
                    seguedToDetail?.summoner = Summoner(data: obj)
                    seguedToDetail?.summonerName = participant.summonerName
                    self.matchTable.deselectRowAtIndexPath(indexPath, animated: true)
                }
            default: break
            }
        }
    }

}
