import UIKit

class CurrentGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var participantTableView: UITableView!
    var summoner: Summoner? {
        willSet{
            if newValue?.id != summoner?.id {
                fetchCurrentGame((newValue?.id)!)
            }
        }
    }
    var game: CurrentGameInfo? {
        didSet{
            game?.split()
            participantTableView.reloadData()
            for participant in (game?.participants)! {
                fetchRankInfo(participant)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        participantTableView.estimatedRowHeight = participantTableView.rowHeight
        participantTableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // MARK: - UITableViewDataSource
    private struct Storyboard {
        static let ReuseCellIdentifier = "participant"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let section = game?.table?.count
            else {
                let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                messageLabel.text = "Not in game.";
                messageLabel.textColor = UIColor.blackColor()
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center
                self.participantTableView.backgroundView = messageLabel;
                self.participantTableView.separatorStyle = .None

                return 0
            }
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
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let team = game?.table![section].first
        if team?.teamId == game!.blueTeamId {
            return "Blue Team"
        }
        else {
            return "Purplue Team"
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func fetchRankInfo(participant: CurrentGameParticipant){
        if participant.summonerId == (summoner?.id)! {
            participant.rankInfo = summoner!.rankInfo
            return
        }
        let url = NSURL(string: "https://na.api.pvp.net/api/lol/na/v2.5/league/by-summoner/\(participant.summonerId)/entry?api_key=\(api_key)")
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
                                    if let entries = resultDict["\(participant.summonerId)"] as? NSArray {
                                        participant.rankInfo = RankInfo(data: entries[0] as! NSDictionary)
                                        self.participantTableView.reloadData()

                                    }
                                }
                            case 404:
                                let obj:NSDictionary = ["name":participant.summonerName, "tier":"provisional", "queue":"SOLO_RANK5X5"]
                                participant.rankInfo = RankInfo(data: obj)
                                self.participantTableView.reloadData()
                            default: print(httpReponse.statusCode)
                                
                                
                            }
                        }
    
                    } catch {}
                }
            })
        }
        task.resume()
    }

    
    func fetchCurrentGame(summonerId: CLong) {
        
        let url = NSURL(string: "https://na.api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/NA1/\(summonerId)?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let resultDict = object as? NSDictionary {
                            self.game = CurrentGameInfo(game: resultDict)
                        }
                    } catch {}
                }
            })
        }
        task.resume()
    }

}
