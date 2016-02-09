import UIKit
import CoreData

class LOLSelfViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var championsTable: UITableView!
    @IBOutlet weak var summonerNameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var averageStatus: UILabel!
    @IBOutlet weak var winRate: UILabel!
    @IBOutlet weak var searchSummoner: UIButton!
    @IBOutlet weak var segmentBar: UISegmentedControl!
    @IBOutlet weak var barItem: UIBarButtonItem!

    
    var summonerName: String = ""{
        didSet{
            summonerNameTextField?.text = summonerName
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    func deleteCoreData() {
        var playerData = [Player]()
        let fetchRequest = NSFetchRequest(entityName: "Players")
        playerData = (try! context.executeFetchRequest(fetchRequest)) as! [Player]
        for player in playerData {
            context.deleteObject(player)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func fetchPlayersRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Players")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    var image: UIImage? {
        get{
            return imageView.image
        }
        set{
            imageView.image = resizeImage(newValue!, newWidth: 50)
            imageView.hidden = false
        }
    }
    
    var rankInfo: RankInfo? {
        didSet{
            image = rankInfo?.image
            summoner!.rankInfo = rankInfo
            rankLabel.text = rankInfo!.getRankWithLP()
            rankLabel.textColor = UIColor.blackColor()
            gameButton.hidden = false
            segmentBar.hidden = false
            rankLabel.hidden = false
        }
    }
    
    var summoner: Summoner? {
        didSet{
            if CheckReachability.isConnectedToNetwork() {
                indicator.startAnimating()
                getRankInfo(summoner!.id)
                getRecentGamesInfo(summoner!.id)
                getChampionRankInfo(summoner!.id)
            }
            else {
                indicator.stopAnimating()
                showReponseMessage("Network Unavailable.")
            }
            
        }
    }
    
    var champions = [ChampionStatus]()
    var averageChampion: ChampionStatus? {
        didSet{
            averageStatus.text = "\((averageChampion?.aggregatedStatsDto?.getAverageStatus())!)"
            winRate.text = " \((averageChampion?.aggregatedStatsDto?.getWinRate())!)"
            averageStatus.hidden = false
            winRate.hidden = false
        }
    }
    
    var recentGames = [GameDto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameButton.hidden = true
        rankLabel.hidden = true
        averageStatus.hidden = true
        winRate.hidden = true
        segmentBar.hidden = true
        indicator.center = view.center
        view.addSubview(indicator)
        championsTable.estimatedRowHeight = championsTable.rowHeight
        championsTable.rowHeight = UITableViewAutomaticDimension
        championsTable.dataSource = self
        let fetchRequest = fetchPlayersRequest()
        
        do {
            let result: NSArray = try context.executeFetchRequest(fetchRequest)
            if result.count > 0 {
                let res = result[0] as! NSManagedObject
                let playerName: String = res.valueForKey("name")! as! String
                summonerNameTextField.text = playerName
                if let playerRegion = res.valueForKey("region") as! String? {
                    region = playerRegion
                }
                else {
                    region = "na"
                }
            }
    
        }catch _ {}
        toggleAddButton()
        barItem.title = region.uppercaseString

        if summonerName != "" {
            summonerNameTextField?.text = summonerName
        }

        championsTable.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedControlActionChanged(sender: UISegmentedControl) {
        championsTable.reloadData()
    }
    
    @IBAction func searchSummoner(sender: UIButton) {
        performAction()
    }
    
    @IBAction func changeRegion(sender: UIBarButtonItem) {
        var regionTitle = "EUW"
        
        if region == "euw" {
            regionTitle = "NA"
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(
            title: regionTitle, style: .Default) { (action) -> Void in
                region = regionTitle.lowercaseString
                self.barItem.title = regionTitle
                self.deleteCoreData()
            })
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .Cancel)
            { (action) in
                // do nothing
            })
        alert.modalPresentationStyle = .Popover
        let ppc = alert.popoverPresentationController
        ppc?.barButtonItem = barItem
        presentViewController(alert, animated: true, completion: nil)
    }
    func performAction() {
        reset()
        self.view.endEditing(true)
        if CheckReachability.isConnectedToNetwork() && summonerNameTextField.text != nil && summonerNameTextField.text != "" {
            let fetchRequest = fetchPlayersRequest()
            do {
                let result: NSArray = try context.executeFetchRequest(fetchRequest)
                if result.count > 0 {
                    let res = result[0] as! NSManagedObject
                    let playerName: String = res.valueForKey("name")! as! String
                    let playerId: NSNumber = res.valueForKey("id")! as! NSNumber
                    if playerName == summonerNameTextField.text! {
                        let obj:NSDictionary = ["name":playerName, "id":playerId]
                        self.summoner = Summoner(data: obj)
                    }
                    else {
                        deleteCoreData()
                        getSummonerId(summonerNameTextField.text!)
                    }
                    
                }
                else {
                    getSummonerId(summonerNameTextField.text!)
                }
            }catch _ {
            }
        }
        else {
            indicator.stopAnimating()
            showReponseMessage("Network Unavailable.")
            searchSummoner.enabled = true
        }
    }
    
    func reset() {
        gameButton.hidden = true
        segmentBar.hidden = true
        rankLabel.hidden = true
        averageStatus.hidden = true
        winRate.hidden = true
        imageView.hidden = true
        searchSummoner.enabled = false
        champions.removeAll()
        recentGames.removeAll()
        indicator.startAnimating()
        showReponseMessage("")
        championsTable.reloadData()

    }
        
    func getRecentGamesInfo(summonerId: CLong) {
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.3/game/by-summoner/\(summonerId)/recent?api_key=\(api_key)")
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
                                    if let entries = resultDict["games"] as? NSArray {
                                        for entry in entries {
                                            let game:GameDto = GameDto(entry: entry as! NSDictionary)
                                            self.recentGames.append(game)
                                            self.recentGames.sortInPlace({ (c1:GameDto, c2:GameDto) -> Bool in
                                                return c1.createDate > c2.createDate
                                            })
                                            
                                            self.championsTable.reloadData()
                                        }
                                        
                                    }
                                }
                            case 404:
                                self.showReponseMessage("Not found a game.")
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
    
    func getChampionRankInfo(summonerId: CLong) {
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.3/stats/by-summoner/\(summonerId)/ranked?season=SEASON2016&api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let resultDict = object as? NSDictionary {
                            if let entries = resultDict["champions"] as? NSArray {
                                for entry in entries {
                                    let rankChampion:ChampionStatus = ChampionStatus(entry: entry as! NSDictionary)
                                    if rankChampion.id != 0 {
                                        self.champions.append(rankChampion)
                                        self.champions.sortInPlace({ (c1:ChampionStatus, c2:ChampionStatus) -> Bool in
                                            return c1.aggregatedStatsDto?.totalSessionsPlayed > c2.aggregatedStatsDto?.totalSessionsPlayed
                                        })
                                    }
                                    else {
                                        self.averageChampion = rankChampion
                                    }
                                    self.championsTable.reloadData()
                                }
                                
                            }
                            
                        }
                    } catch {}
                }
            })
        }
        task.resume()
    }
    
    
    func getRankInfo(summonerId: CLong) {
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v2.5/league/by-summoner/\(summonerId)/entry?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! NSHTTPURLResponse? {
                            self.indicator.stopAnimating()
                            self.searchSummoner.enabled = true
                        
                            switch(httpReponse.statusCode) {
                            
                            case 200:
                                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    if let entries = resultDict["\(summonerId)"] as? NSArray {
                                        self.rankInfo = RankInfo(data: entries[0] as! NSDictionary)
                                    }
                                }
                            case 404:
                                self.rankLabel.text = "Unranked"
                                self.rankLabel.hidden = false
                                self.gameButton.hidden = false
                            
                                self.image = UIImage(named: "provisional")
                            case 429:
                                self.showReponseMessage("Rate Limit Exceeded.")
                            case 500, 503:
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
    
    func getSummonerId(summonerName: String) {
        let urlSummonerName: String = summonerName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let trimmedSummonerName = summonerName.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.4/summoner/by-name/\(urlSummonerName)?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! NSHTTPURLResponse? {
                            self.indicator.stopAnimating()
                            self.searchSummoner.enabled = true

                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    if let dataSet = resultDict.objectForKey(trimmedSummonerName.lowercaseString) as? NSDictionary {
                                        self.summoner = Summoner(data: dataSet)
                                        let context = self.context
                                        let ent = NSEntityDescription.entityForName("Players", inManagedObjectContext: context)
                                        let nPlayer = Player(entity: ent!, insertIntoManagedObjectContext: context)
                                        nPlayer.name = self.summonerNameTextField.text!
                                        nPlayer.id = self.summoner?.id
                                        nPlayer.region = region

                                        do {
                                            try context.save()
                                        } catch _ {
                                        }
                                    }
                                }
                            case 404:
                                self.rankLabel.text = "Not Found"
                                self.rankLabel.textColor = UIColor.redColor()
                                self.rankLabel.hidden = false
                                self.gameButton.hidden = true
                                self.segmentBar.hidden = true
                                
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
        let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        self.championsTable.backgroundView = messageLabel
        self.championsTable.separatorStyle = .None
        
    }

    
    // MARK: - UITableViewDataSource
    private struct Storyboard {
        static let ReuseCellIdentifier = "champion"
        static let ReuseMatchCellIdentifer = "match"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch segmentBar.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseMatchCellIdentifer) as! RecentGameTableViewCell?
            cell?.game = recentGames[indexPath.row]
            cell?.layer.borderColor = UIColor.grayColor().CGColor
            cell?.layer.borderWidth = 2.0
            if cell?.game?.stats?.win == true {
                cell?.backgroundColor = UIColor.greenColor()
            }
            else {
                cell?.backgroundColor = UIColor.redColor()
            }
            return cell!
        case 1:
            fallthrough
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! ChampionTableViewCell?
            cell?.champion = champions[indexPath.row]
            return cell!
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentBar.selectedSegmentIndex {
        case 0: return recentGames.count
        case 1: return champions.count
        default: return 0
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let DestViewController: CurrentGameViewController = segue.destinationViewController as! CurrentGameViewController
        DestViewController.summoner = self.summoner
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performAction()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func toggleAddButton() {
        if summonerNameTextField.text!.isEmpty {
            searchSummoner.enabled = false
        }
        else {
            searchSummoner.enabled = true
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == summonerNameTextField {
            let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            if !text.isEmpty {
                searchSummoner.enabled = true
            }
            else {
                searchSummoner.enabled = false
            }
        }
        return true
    }

}

extension RankInfo {
    var image: UIImage? {
        let rank = getRank().lowercaseString
        if let image = UIImage(named: rank){
            return image
        }
        else {
            return UIImage(named: "provisional")
        }
    }
}

extension ChampionStatus {
    var image: UIImage? {
        if let championString = championsMap[id] {
            return UIImage(named: championString)
        }
        else {
            return UIImage(named: "unknown")
        }
    }
}
