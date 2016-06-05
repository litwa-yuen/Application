import UIKit
import CoreData
import GoogleMobileAds

class LOLSelfViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, GADBannerViewDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var championsTable: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var averageStatus: UILabel!
    @IBOutlet weak var winRate: UILabel!
    @IBOutlet weak var segmentBar: UISegmentedControl!
    @IBOutlet weak var searchSummonerButton: UIBarButtonItem!
    @IBOutlet weak var googleBannerView: GADBannerView!
    @IBOutlet weak var settingBarButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    // MARK: - Properties
    var selectedIndexPath: NSIndexPath?
    let searchText: UITextField = UITextField(frame: CGRectMake(0,0,280,25))
    
    var summonerName: String = ""{
        didSet{
            searchText.text = summonerName
            searchSummonerButton.enabled = true
        }
    }
    
    var image: UIImage? {
        get{
            return imageView.image
        }
        set{
            imageView.image = newValue
            imageView.hidden = false
        }
    }
    
    var rankInfo: RankInfo? {
        didSet{
            image = rankInfo?.image
            summoner!.rankInfo = rankInfo
            rankLabel.text = rankInfo!.getRankWithLP()
            rankLabel.textColor = UIColor.blackColor()
            if isFavorite() {
                favoriteButton.setImage(UIImage(named: "full star"), forState: .Normal)
            }
            segmentBar.hidden = false
            favoriteButton.hidden = false
            rankLabel.hidden = false
        }
    }
    
    var summoner: Summoner? {
        didSet{
            if CheckReachability.isConnectedToNetwork() {
                searchText.text = summoner?.name
                indicator.startAnimating()
                getRankInfo(summoner!.id)
                getRecentGamesInfo(summoner!.id)
                getChampionRankInfo(summoner!.id)
                getChampionMastery(summoner!.id)
            }
            else {
                showReponseMessage("Network Unavailable.")
            }
            
        }
    }
    
    var champions = [ChampionStatus]()
    var championMastery = [ChampionMasteryDTO]()
    var averageChampion: ChampionStatus? {
        didSet{
            averageStatus.text = "\((averageChampion?.aggregatedStatsDto?.getAverageStatus())!)"
            winRate.text = " \((averageChampion?.aggregatedStatsDto?.getWinRate())!)"
            averageStatus.hidden = false
            winRate.hidden = false
        }
    }
    
    var recentGames = [GameDto]()
    
    var regionTitle = "NA"
    
    var messageLabel = UILabel()
    
    // MARK: - NSFetchedResultsControllerDelegate
    let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    
    func fetchPlayersRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Players")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func fetchMeRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Me")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func deleteMeCoreData() {
        let result: NSArray = (try! context.executeFetchRequest(fetchMeRequest())) as! [Player]
        for me in result {
            context.deleteObject(me as! NSManagedObject)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        rankLabel.font = Storyboard.TitleFont
        averageStatus.font = Storyboard.DetailFont
        winRate.font = Storyboard.DetailFont
        googleBannerView.adUnitID = AdMobAdUnitID
        googleBannerView.adSize = kGADAdSizeSmartBannerPortrait
        googleBannerView.delegate = self
        googleBannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [testDevice]
        googleBannerView.loadRequest(request)

        view.bringSubviewToFront(favoriteButton)
        favoriteButton.contentEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
        
        setUpSearchBar()
        
        messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(messageLabel)

        navigationItem.titleView = searchText
        indicator.center = view.center
        view.addSubview(indicator)
        championsTable.estimatedRowHeight = championsTable.rowHeight
        championsTable.rowHeight = UITableViewAutomaticDimension
        reset()
        if summoner?.id == nil {
            let result: [Player] = (try! context.executeFetchRequest(fetchPlayersRequest())) as! [Player]
            if !result.isEmpty {
                if let playerRegion = result.first?.region {
                    region = playerRegion
                }
                else {
                    region = "na"
                }
            }
        }
        regionTitle = region
        if summonerName != "" {
            searchText.text = summonerName
        }
        toggleAddButton(searchText.text!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segmentBar.selectedSegmentIndex = 0
        championsTable.allowsSelection = true
        if regionTitle != region {
            regionTitle = region
            searchText.text = ""
            reset()
        }
        discardKeyboard()
        championsTable.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        tryToRateApp()
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
        
        let rightView = UIView()
        
        rightView.frame = CGRectMake(0, 0, 20, 20)
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let button = UIButton(frame: CGRectMake(-1, 2, 14, 14))
        button.setBackgroundImage(UIImage(named: "clock"), forState: .Normal)
        button.addTarget(self, action: #selector(LOLSelfViewController.recentSearch), forControlEvents: UIControlEvents.TouchUpInside)
        rightView.addSubview(button)
        searchText.rightViewMode = UITextFieldViewMode.UnlessEditing
        searchText.rightView = rightView
    }
    
    func reset() {
        championsTable.allowsSelection = true
        segmentBar.setWidth(0, forSegmentAtIndex: 1)
        segmentBar.setEnabled(true, forSegmentAtIndex: 1)
        segmentBar.hidden = true
        favoriteButton.hidden = true
        favoriteButton.setImage(UIImage(named: "star"), forState: .Normal)
        rankLabel.hidden = true
        rankLabel.textColor = UIColor.blackColor()
        averageStatus.hidden = true
        winRate.hidden = true
        imageView.hidden = true
        searchSummonerButton.enabled = true
        messageLabel.text = ""
        champions.removeAll()
        recentGames.removeAll()
        championMastery.removeAll()
        segmentBar.selectedSegmentIndex = 0
        discardKeyboard()
        championsTable.reloadData()
    }
    
    func discardKeyboard() {
        searchText.endEditing(true)
    }
    
    func loading() {
        searchSummonerButton.enabled = false
        indicator.startAnimating()
    }
    
    // MARK: - Button Action
    @IBAction func segmentedControlActionChanged(sender: UISegmentedControl) {
        discardKeyboard()
        if segmentBar.selectedSegmentIndex == 0 {
            championsTable.allowsSelection = true
            championsTable.reloadData()
        }
            
        else if segmentBar.selectedSegmentIndex == 1 {
            championsTable.allowsSelection = false
            championsTable.reloadData()
        }
        else if segmentBar.selectedSegmentIndex == 2 {
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
    
    func recentSearch() {
        let tvc = self.storyboard?.instantiateViewControllerWithIdentifier("RecentSearchesViewController") as? RecentSearchesViewController
        self.navigationController?.pushViewController(tvc!, animated: true)
    }
    
    @IBAction func favorite(sender: UIButton) {
        if isFavorite() {
            favoriteButton.setImage(UIImage(named: "star"), forState: .Normal)
            deleteMeCoreData()
        }
        else {
            deleteMeCoreData()
            let ent = NSEntityDescription.entityForName("Me", inManagedObjectContext: context)
            let me = Me(entity: ent!, insertIntoManagedObjectContext: context)
            me.name = summoner!.name
            me.id = summoner!.id
            me.region = region
            me.date = NSDate()
            me.homePage = 1
            do {
                try context.save()
                favoriteButton.setImage(UIImage(named: "full star"), forState: .Normal)
            } catch _ {
            }

        }
    }
    
    func isFavorite() -> Bool {
        let result: [Me] = (try! context.executeFetchRequest(fetchMeRequest())) as! [Me]
        if !result.isEmpty {
            if result.first?.id == summoner?.id && result.first?.region == region {
                return true
            }
        }
        return false
    }
    
    func performAction() {
        reset()
        loading()
        if CheckReachability.isConnectedToNetwork() {
            let fetchRequest = fetchPlayersRequest()
            
            let playersData = (try! context.executeFetchRequest(fetchRequest)) as! [Player]
            var found = false
            for player in playersData {
                if uniformName(player.name!) == uniformName(searchText.text!) && player.region == region {
                    found = true
                    let obj:NSDictionary = ["name":player.name!, "id":player.id!]
                    player.date = NSDate()
                    do {
                        try context.save()
                    } catch _ {
                    }
                    self.summoner = Summoner(data: obj)
                }
            }
            if found == false {
                getSummonerId(searchText.text!)
            }
            
        }
        else {
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
                                                return c1.createDate.longLongValue > c2.createDate.longLongValue
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
    
    func getChampionMastery(summonerId: CLong) {
        let url = NSURL(string: "https://\(region).api.pvp.net/championmastery/location/\(platformMap[region]!)/player/\(summonerId)/champions?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let entries = object as? NSArray {
                            for entry in entries {
                                let championMastery:ChampionMasteryDTO = ChampionMasteryDTO(data: entry as! NSDictionary)
                                self.championMastery.append(championMastery)
                                self.championMastery.sortInPlace({ (c1:ChampionMasteryDTO, c2:ChampionMasteryDTO) -> Bool in
                                    return c1.championPoints > c2.championPoints
                                })
                                self.championsTable.reloadData()
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
                                self.favoriteButton.hidden = false
                                self.segmentBar.hidden = false
                                if self.isFavorite() {
                                    self.favoriteButton.setImage(UIImage(named: "full star"), forState: .Normal)
                                }
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
                                        nPlayer.date = NSDate()
                                        
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
                                self.segmentBar.hidden = true
                                self.favoriteButton.hidden = true
                                
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
    
    func uniformName(summonerName: String) -> String {
        return summonerName.stringByReplacingOccurrencesOfString(" ", withString: "").lowercaseString
    }
    
    func showReponseMessage(message: String) {
        messageLabel.text = message
        indicator.stopAnimating()
        messageLabel.hidden = false
    }
    
    // MARK: - UITableViewDataSource
    private struct Storyboard {
        static let ReuseCellIdentifier = "champion"
        static let ReuseMatchCellIdentifer = "match"
        static let ReuseMasteryCellIdentifer = "mastery"
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
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! ChampionTableViewCell?
            cell?.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).CGColor
            cell?.layer.borderWidth = 1.0
            cell?.champion = champions[indexPath.row]
            return cell!
        case 2:
            fallthrough
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseMasteryCellIdentifer) as! ChampionMasteryTableViewCell?
            cell?.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).CGColor
            cell?.layer.borderWidth = 1.0
            cell?.mastery = championMastery[indexPath.row]
            return cell!
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentBar.selectedSegmentIndex {
        case 0: return recentGames.count
        case 1: return champions.count
        case 2: return championMastery.count
        default: return 0
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        discardKeyboard()
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
    
    // MARK: - GADBannerViewDelegate
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        bannerView.hidden = false
        bannerView.alpha = 0
        UIView.animateWithDuration(1, animations: {
            bannerView.alpha = 1
        })
    }
    
    func adView(bannerView: GADBannerView!,
                didFailToReceiveAdWithError error: GADRequestError!) {
        bannerView.alpha = 1
        UIView.animateWithDuration(1, animations: {
            bannerView.alpha = 0
        })
        bannerView.hidden = true
    }
    
    func showRateAppAlert() {
        let alert = UIAlertController(title: "Rate \(APP_NAME)", message: "If you enjoy using \(APP_NAME), would you mind taking a moment to rate it? It wouldn't take more than a minute. Thanks for your support!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Rate It Now", style: UIAlertActionStyle.Default, handler: { alertAction in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")
            UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id\(APP_ID)")!)
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Remind me later", style: UIAlertActionStyle.Default, handler: { alertAction in
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "numLaunches")
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertActionStyle.Default, handler: { alertAction in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "neverRate")       // Hide the Alert
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tryToRateApp() {
        let neverRate = NSUserDefaults.standardUserDefaults().boolForKey("neverRate")
        let numLaunches = NSUserDefaults.standardUserDefaults().integerForKey("numLaunches") + 1
        if (!neverRate && (numLaunches >= minNumberOfSessions))
        {
            showRateAppAlert()
        }
        NSUserDefaults.standardUserDefaults().setInteger(numLaunches, forKey: "numLaunches")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        discardKeyboard()
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.MatchDetailIdentifier:
                let cell = sender as? RecentGameTableViewCell
                let seguedToDetail = segue.destinationViewController as? MatchViewController
                guard let matchId = cell?.game?.gameId else { return }
                guard let fellowPlayers = cell?.game?.fellowPlayers else { return }
                let matchDetail = (fellowPlayers, matchId, (summoner?.name)!, (summoner?.id)!)
                seguedToDetail?.matchInit = matchDetail
                
            default: break
            }
        }
    }
}