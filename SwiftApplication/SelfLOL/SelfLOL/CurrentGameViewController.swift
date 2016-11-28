import UIKit
import Firebase
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


class CurrentGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UI Outlet
    @IBOutlet weak var participantTableView: UITableView!
    @IBOutlet weak var statusBarButton: UIBarButtonItem!
    
    // MARK: - Properties 
    var summoner: Summoner? {
        willSet{
            indicator.startAnimating()
            if CheckReachability.isConnectedToNetwork() {
                fetchCurrentGame((newValue?.id)!)
            }
            else {
                showReponseMessage("Network Unavailable.")
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
    
    var isMainPage = false 
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var messageLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAnalytics.logEvent(withName: "game_clicked", parameters: [
            "region": region as NSObject
            ])

        participantTableView.estimatedRowHeight = participantTableView.rowHeight
        participantTableView.rowHeight = UITableViewAutomaticDimension
        participantTableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Storyboard.ReuseFooterIdentifier)
        indicator.center = view.center
        self.navigationItem.setHidesBackButton(false, animated: false)
        if !isMainPage && CheckReachability.isConnectedToNetwork(){
            statusBarButton.isEnabled = false
            statusBarButton.title = ""
        }
        
        view.addSubview(indicator)
    }
        
    // MARK: - UITableViewDataSource
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "participant"
        static let ReuseFooterIdentifier = "banned"
        static let DetailIdentifier = "detail"
        static let StatusIdentifier = "status"
        static let BorderColor = "607D8B"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return game?.table?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game?.table![section].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as! ParticipantTableViewCell
    
        cell.participant = game?.table![(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).cgColor
        cell.layer.borderWidth = 1.0
        cell.runeButton.tag = (indexPath as NSIndexPath).row
        cell.runeButton.addTarget(self, action: #selector(CurrentGameViewController.checkRune(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let team = game?.table![section].first
        if team?.teamId == game!.blueTeamId {
            return "Blue Team"
        }
        else {
            return "Purple Team"
        }
    }
    
    @IBAction func checkRune(_ sender: UIButton) {
        FIRAnalytics.logEvent(withName: "rune_clicked", parameters: [
            "region": region as NSObject
            ])

        let butttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.participantTableView)
        if let indexPath:IndexPath = self.participantTableView.indexPathForRow(at: butttonPosition) {
            let participant:CurrentGameParticipant = (game?.table![(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])!
            let tvc = self.storyboard?.instantiateViewController(withIdentifier: "RunesViewController") as? RunesViewController
            tvc?.runes = participant.runes
            tvc?.title = "\(participant.summonerName)'s Rune"
            self.navigationController?.pushViewController(tvc!, animated: true)

        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if game?.bannedChampions?.count > 0 {
            return 50
        }
        else {
            return 0
        }
    }
    // MARK: - banned champions table footer view
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
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

    // MARK: - League of Lengends API
    func fetchCurrentGame(_ summonerId: CLong) {
        let url = URL(string: "https://\(region).api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/\(platformMap[region]!)/\(summonerId)?api_key=\(api_key)")
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! HTTPURLResponse? {
                            self.indicator.stopAnimating()
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try JSONSerialization.jsonObject(with: data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    self.game = CurrentGameInfo(game: resultDict)
                                    if self.game?.gameId == currentGame?.gameId {
                                        self.game = currentGame
                                    }
                                }
                            case 404:
                                self.showReponseMessage("\((self.summoner?.name)!) is not currently in a game.")
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
    
    func fetchRankInfo(_ participant: CurrentGameParticipant){
        if participant.summonerId == (summoner?.id)! {
            if summoner?.rankInfo != nil {
                participant.rankInfo = summoner!.rankInfo
                return
            }
        }
        let url = URL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v2.5/league/by-summoner/\(participant.summonerId)/entry?api_key=\(api_key)")
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! HTTPURLResponse? {
                            self.indicator.stopAnimating()
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try JSONSerialization.jsonObject(with: data!, options: [])
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
        }) 
        task.resume()
    }
    
    func showReponseMessage(_ message: String) {
        indicator.stopAnimating()
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.center
        participantTableView.isHidden = true
        view.addSubview(messageLabel)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.DetailIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = participantTableView.indexPath(for: cell!) {
                    let seguedToDetail = segue.destination as? LOLSelfViewController
                    let participant = (game?.table![(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])! as CurrentGameParticipant
                    let obj:NSDictionary = ["name":participant.summonerName, "id":participant.summonerId]
                    seguedToDetail?.summoner = Summoner(data: obj)
                    seguedToDetail?.summonerName = participant.summonerName
                    self.participantTableView.deselectRow(at: indexPath, animated: true)
                }
            case Storyboard.StatusIdentifier:
                let seguedToDetail = segue.destination as? LOLSelfViewController
                seguedToDetail?.summoner = summoner
                seguedToDetail?.summonerName = (summoner?.name)!
            default: break
            }
        }
    }

}
