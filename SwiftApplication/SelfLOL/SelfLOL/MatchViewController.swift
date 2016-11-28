import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
            if match?.queueType.contains("ARAM") == true {
                queueTypeLabel.text = "ARAM"
            }
            else if match?.queueType.contains("RANK") == true {
                queueTypeLabel.text = "Ranked"
            }
            else if match?.queueType.contains("BOT") == true {
                queueTypeLabel.text = "BOT"
            }
            else {
                queueTypeLabel.text = "Normal"
            }
            queueTypeLabel.font = Storyboard.CellFont
            timeAgoLabel.text = timeAgoSince(Date(timeIntervalSince1970: (Double)((match?.matchCreation.int64Value)!/1000)))
            timeAgoLabel.font = Storyboard.CellFont
            playedTimeLabel.text = "\(Int((match?.matchDuration)!/60))m \((match?.matchDuration)!%60)s"
            playedTimeLabel.font = Storyboard.CellFont

            _ = match!.split(fellowPlayers)
            resultLabel.text = match?.getResult()
            resultLabel.font = Storyboard.CellBoldFont
            matchDetailStack.isHidden = false
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

    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: - setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchDetailStack.isHidden = true

        if matchId != 0 && matchId == matchDetail?.matchId {
            match = matchDetail
        }
        matchTable.estimatedRowHeight = matchTable.rowHeight
        matchTable.rowHeight = UITableViewAutomaticDimension
        matchTable.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Storyboard.ReuseFooterIdentifier)
        indicator.center = view.center
        view.addSubview(indicator)
        matchTable.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "player"
        static let SummonerIdentifier = "summoner"
        static let ReuseFooterIdentifier = "banned"
        static let BorderColor = "607D8B"
        static let CellFont = UIFont(name: "Helvetica", size: 15)
        static let CellBoldFont = UIFont(name: "Helvetica-Bold", size: 16)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return match?.table?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return match?.table![section].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as! MatchTableViewCell
        cell.maxDamage = (match?.maxDamage)!
        cell.participant = match?.table![(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).cgColor
        cell.layer.borderWidth = 1.0
        
        return cell
    }
    
    private func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let team = match?.teams![section]

        if team?.bans?.count > 0 {
            return 50
        }
        else {
            return 0
        }
    }
    
    private func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let team = match?.teams![section]
        
        var champs:[String] = []
        if let bannedChampions = team?.bans {
            for champion in bannedChampions {
                if let bannedChampion = championsMap[champion.championId] {
                    champs.append(bannedChampion)
                }
                else {
                    champs.append("unknown")
                }                
            }
        }

        if !champs.isEmpty {
            let h = tableView
                .dequeueReusableHeaderFooterView(withIdentifier: Storyboard.ReuseFooterIdentifier)!
            h.backgroundView = UIView()
            h.backgroundView?.backgroundColor = UIColor.black
            let lab = UILabel()
            lab.font = UIFont(name:"Helvetica-Bold", size:12)
            lab.textColor = UIColorFromRGB("D50000")
            lab.text = "Ban:"
            lab.backgroundColor = UIColor.clear
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
            NSLayoutConstraint.activate([
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:[lab(30)]-10-[champ3(50)]-5-[champ2(50)]-5-[champ1(50)]-5-|",
                    options:[], metrics:nil, views:["champ1":champ1, "lab":lab, "champ2":champ2, "champ3":champ3]),
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[champ1]|", options:[], metrics:nil, views:["champ1":champ1]),
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[champ2]|", options:[], metrics:nil, views:["champ2": champ2]),
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[champ3]|", options:[], metrics:nil, views:["champ3": champ3]),
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[lab]|", options:[], metrics:nil, views:["lab":lab])
                ].joined().map{$0})
            
            return h

        }
        else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    func fetchMatchDetail(_ matchId: NSNumber) {
        indicator.startAnimating()
        let url = URL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v2.2/match/\(matchId)?api_key=\(api_key)")
        
        
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! HTTPURLResponse? {
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try JSONSerialization.jsonObject(with: data!, options: [])
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
        }) 
        task.resume()
    }

    func fetchRankInfo(_ participant: Participant){
        indicator.startAnimating()
        let url = URL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.4/summoner/\(participant.summonerId)?api_key=\(api_key)")
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! HTTPURLResponse? {
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try JSONSerialization.jsonObject(with: data!, options: [])
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
        }) 
        task.resume()
    }
    
    func showReponseMessage(_ message: String) {
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.center
        view.addSubview(messageLabel)
        indicator.stopAnimating()
        messageLabel.isHidden = false
    }

    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SummonerIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = matchTable.indexPath(for: cell!) {
                    let seguedToDetail = segue.destination as? LOLSelfViewController
                    let participant = (match?.table![(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])! as CurrentGameParticipant
                    let obj:NSDictionary = ["name":participant.summonerName, "id":participant.summonerId]
                    seguedToDetail?.summoner = Summoner(data: obj)
                    seguedToDetail?.summonerName = participant.summonerName
                    self.matchTable.deselectRow(at: indexPath, animated: true)
                }
            default: break
            }
        }
    }

}
