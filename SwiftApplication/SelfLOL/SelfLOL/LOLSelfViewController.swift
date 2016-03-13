import UIKit
import CoreData

class LOLSelfViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var championsTable: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var averageStatus: UILabel!
    @IBOutlet weak var winRate: UILabel!
    @IBOutlet weak var segmentBar: UISegmentedControl!
    @IBOutlet weak var regionBarItem: UIBarButtonItem!
    @IBOutlet weak var searchSummonerButton: UIBarButtonItem!
    
    // MARK: - Properties
    var selectedIndexPath: NSIndexPath?
    let searchText: UITextField = UITextField(frame: CGRectMake(0,0,280,25))
    
    var summonerName: String = ""{
        didSet{
            searchText.text = summonerName
        }
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
            segmentBar.hidden = false
            rankLabel.hidden = false
            championsTable.hidden = false
        }
    }
    
    var summoner: Summoner? {
        didSet{
            if CheckReachability.isConnectedToNetwork() {
                currentSummoner = (summoner?.name, summoner?.id)
                searchText.text = summoner?.name
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

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        rankLabel.font = Storyboard.TitleFont
        averageStatus.font = Storyboard.DetailFont
        winRate.font = Storyboard.DetailFont
        setUpSearchBar()
        navigationItem.titleView = searchText
        indicator.center = view.center
        view.addSubview(indicator)
        championsTable.estimatedRowHeight = championsTable.rowHeight
        championsTable.rowHeight = UITableViewAutomaticDimension
        reset()
        
        let fetchRequest = fetchPlayersRequest()
        
        do {
            let result: NSArray = try context.executeFetchRequest(fetchRequest)
            if result.count > 0 {
                let res = result[0] as! NSManagedObject
                let playerName: String = res.valueForKey("name")! as! String
                searchText.text = playerName
                if let playerRegion = res.valueForKey("region") as! String? {
                    region = playerRegion
                }
                else {
                    region = "na"
                }
            }
    
        }catch _ {}
        regionBarItem.title = region.uppercaseString

        if summonerName != "" {
            searchText.text = summonerName
        }
        toggleAddButton(searchText.text!)
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segmentBar.selectedSegmentIndex = 0
        championsTable.allowsSelection = true
        championsTable.reloadData()
    }
    
    func setUpSearchBar() {
        searchText.delegate = self
        searchText.placeholder = "Enter the Summoner's name"
        searchText.contentHorizontalAlignment = .Center
        searchText.contentVerticalAlignment = .Center
        searchText.borderStyle = .RoundedRect
        searchText.font = UIFont(name: "Helvetica", size: 14)
        searchText.clearButtonMode = .WhileEditing
        searchText.textAlignment = .Center
        searchText.returnKeyType = .Search
        searchText.enablesReturnKeyAutomatically = true
    }
    
    func reset() {
        championsTable.allowsSelection = true
        segmentBar.setWidth(0, forSegmentAtIndex: 1)
        segmentBar.setEnabled(true, forSegmentAtIndex: 1)
        segmentBar.hidden = true
        championsTable.hidden = true
        rankLabel.hidden = true
        averageStatus.hidden = true
        winRate.hidden = true
        imageView.hidden = true
        searchSummonerButton.enabled = true
        champions.removeAll()
        recentGames.removeAll()
        segmentBar.selectedSegmentIndex = 0
        showReponseMessage("")
        searchText.endEditing(true)
        championsTable.reloadData()
    }
    
    func loading() {
        searchSummonerButton.enabled = false
        indicator.startAnimating()
    }
    
    // MARK: - Button Action
    @IBAction func segmentedControlActionChanged(sender: UISegmentedControl) {
        if segmentBar.selectedSegmentIndex == 0 {
            championsTable.allowsSelection = true
            championsTable.reloadData()
        }
            
        else if segmentBar.selectedSegmentIndex == 1 {
            championsTable.allowsSelection = false
            championsTable.reloadData()
        }
        else {
            let tvc = self.storyboard?.instantiateViewControllerWithIdentifier("CurrentGameViewController") as? CurrentGameViewController
            tvc?.summoner = self.summoner
            self.navigationController?.pushViewController(tvc!, animated: true)
        }
    }
    
    @IBAction func searchSummonerBarAction(sender: UIBarButtonItem) {
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
                self.regionBarItem.title = regionTitle
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
        ppc?.barButtonItem = regionBarItem
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func performAction() {
        reset()
        loading()
        if CheckReachability.isConnectedToNetwork() && searchText.text != nil && searchText.text != "" {
            let fetchRequest = fetchPlayersRequest()
            do {
                let result: NSArray = try context.executeFetchRequest(fetchRequest)
                if result.count > 0 {
                    let res = result[0] as! NSManagedObject
                    let playerName: String = res.valueForKey("name")! as! String
                    let playerId: NSNumber = res.valueForKey("id")! as! NSNumber
                    if playerName == searchText.text! {
                        let obj:NSDictionary = ["name":playerName, "id":playerId]
                        self.summoner = Summoner(data: obj)
                    }
                    else {
                        deleteCoreData()
                        getSummonerId(searchText.text!)
                    }
                }
                else {
                    getSummonerId(searchText.text!)
                }
            }catch _ {
            }
        }
        else {
            indicator.stopAnimating()
            championsTable.hidden = false
            showReponseMessage("Network Unavailable.")
            searchSummonerButton.enabled = true
        }
    }
    // MARK: - League of Lengends API
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
                            self.searchSummonerButton.enabled = true
                        
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
                                self.segmentBar.setEnabled(false, forSegmentAtIndex: 1)
                                self.segmentBar.setWidth(0.1, forSegmentAtIndex: 1)
                                self.segmentBar.hidden = false
                                self.championsTable.hidden = false
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
                            self.searchSummonerButton.enabled = true

                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    if let dataSet = resultDict.objectForKey(trimmedSummonerName.lowercaseString) as? NSDictionary {
                                        self.summoner = Summoner(data: dataSet)
                                        let context = self.context
                                        let ent = NSEntityDescription.entityForName("Players", inManagedObjectContext: context)
                                        let nPlayer = Player(entity: ent!, insertIntoManagedObjectContext: context)
                                        nPlayer.name = self.searchText.text!
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
                                self.championsTable.hidden = true
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
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        self.championsTable.backgroundView = messageLabel
        self.championsTable.separatorStyle = .None
    }
    
    // MARK: - UITableViewDataSource
    private struct Storyboard {
        static let ReuseCellIdentifier = "champion"
        static let ReuseMatchCellIdentifer = "match"
        static let MatchDetailIdentifier = "matchDetail"
        static let BorderColor = "607D8B"
        static let TitleFont = UIFont(name: "Helvetica-Bold", size: 18)
        static let DetailFont = UIFont(name: "Helvetica", size: 16)

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch segmentBar.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseMatchCellIdentifer) as! RecentGameTableViewCell?
            cell?.game = recentGames[indexPath.row]
            cell?.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).CGColor
            cell?.layer.borderWidth = 1.0
            return cell!
        case 1:
            fallthrough
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! ChampionTableViewCell?
            cell?.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).CGColor
            cell?.layer.borderWidth = 1.0
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
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performAction()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.searchText.endEditing(true)
    }
    
    func toggleAddButton(text: String) {
        if text.isEmpty {
            searchSummonerButton.enabled = false
        }
        else {
            searchSummonerButton.enabled = true
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == searchText {
            let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            toggleAddButton(text)
        }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        searchSummonerButton.enabled = false
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.MatchDetailIdentifier:
                let cell = sender as? RecentGameTableViewCell
                let seguedToDetail = segue.destinationViewController as? MatchViewController
                guard let matchId = cell?.game?.gameId else { return }
                guard let fellowPlayers = cell?.game?.fellowPlayers else { return }
                let matchDetail = (fellowPlayers, matchId, searchText.text!)
                seguedToDetail?.matchInit = matchDetail
                
            default: break
            }
        }
        else {
            let DestViewController: CurrentGameViewController = segue.destinationViewController as! CurrentGameViewController
            DestViewController.summoner = self.summoner
        }
    }
}