import UIKit

class MatchViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var matchTable: UITableView!
    var match: MatchDetail? {
        didSet{
            match!.split(fellowPlayers)
            matchTable.reloadData()
            if match != nil && matchDetail?.matchId != match?.matchId {
                for participant in (match?.participants)! {
                    if participant.summonerId == 0 {
                        participant.summonerName = currentSummoner.0!
                        participant.summonerId = currentSummoner.1!
                    }
                    else {
                        fetchRankInfo(participant)
                    }

                }
                matchDetail = self.match
            }
            else {
                indicator.stopAnimating()
            }
        }
    }

    var matchId:CLong = 0 {
        didSet{
            if CheckReachability.isConnectedToNetwork() {
                fetchMatchDetail()
            }
            else {
                showReponseMessage("Network Unavailable.")
            }
        }
    }
    
    var fellowPlayers: [PlayerDto] = []
    
    var searchedSummonerName: String = ""
    
    var matchInit = ([PlayerDto](),0,"") {
        didSet {
            indicator.startAnimating()
            fellowPlayers = matchInit.0
            matchId = matchInit.1
            searchedSummonerName = matchInit.2
        }
    }

    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchTable.estimatedRowHeight = matchTable.rowHeight
        matchTable.rowHeight = UITableViewAutomaticDimension
        indicator.center = view.center
        view.addSubview(indicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetchMatchDetail() {
        
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v2.2/match/\(matchId)?api_key=\(api_key)")
        

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
                                    self.match = MatchDetail(match: resultDict)
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
    
    // MARK: - UITableViewDataSource
    private struct Storyboard {
        static let ReuseCellIdentifier = "player"
        static let SummonerIdentifier = "summoner"
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        guard let section = match?.table?.count else { return 0 }
        return section
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let counter = match?.table![section].count
            else {
                return 0
        }
        return counter
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! MatchTableViewCell
        
        cell.participant = match?.table![indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let team = match?.table![section].first
        var result  = ""
        if team?.participantStats.win == true {
            result = "Victory"
        }
        else {
            result = "Defeat"
        }
        if team?.teamId == match!.blueTeamId {
            
            return "Blue Team \(result)"
        }
        else {
            return "Purple Team \(result)"
        }
    }

    
    func showReponseMessage(message: String) {
        indicator.stopAnimating()
        let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        self.matchTable.backgroundView = messageLabel
        self.matchTable.separatorStyle = .None
        match = nil
        matchTable.reloadData()
    }
    
    func fetchRankInfo(participant: Participant){
        
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.4/summoner/\(participant.summonerId)?api_key=\(api_key)")
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
                                    if let entries = resultDict["\(participant.summonerId)"] as? NSDictionary {
                                        participant.summonerName = (entries["name"] as? String)!
                                        self.matchTable.reloadData()
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
