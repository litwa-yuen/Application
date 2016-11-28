import UIKit
import CoreData
import GoogleMobileAds
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
    var selectedIndexPath: IndexPath?
    let searchText: UITextField = UITextField(frame: CGRect(x: 0,y: 0,width: 280,height: 25))
    
    var summonerName: String = ""{
        didSet{
            searchText.text = summonerName
            searchSummonerButton.isEnabled = true
        }
    }
    
    var image: UIImage? {
        get{
            return imageView.image
        }
        set{
            imageView.image = newValue
            imageView.isHidden = false
        }
    }
    
    var rankInfo: RankInfo? {
        didSet{
            image = rankInfo?.image
            summoner!.rankInfo = rankInfo
            rankLabel.text = rankInfo!.getRankWithLP()

            rankLabel.textColor = UIColor.black
            if isFavorite() {
                favoriteButton.setImage(UIImage(named: "full star"), for: UIControlState())
            }
            segmentBar.isHidden = false
            favoriteButton.isHidden = false
            rankLabel.isHidden = false
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
            averageStatus.isHidden = false
            winRate.isHidden = false
        }
    }
    
    var recentGames = [GameDto]()
    
    var regionTitle = "NA"
    
    var messageLabel = UILabel()
    
    var showAlert = false
    
    var interstitial: GADInterstitial!
    
    // MARK: - NSFetchedResultsControllerDelegate
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    func fetchPlayersRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func fetchMeRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Me")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func deleteMeCoreData() {
        let result: NSArray = (try! context.fetch(fetchMeRequest())) as! [Me] as NSArray
        for me in result {
            context.delete(me as! NSManagedObject)
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
        createAndLoadAds()


        view.bringSubview(toFront: favoriteButton)
        favoriteButton.contentEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
        
        setUpSearchBar()
        
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        messageLabel.font = UIFont(name: "Helvetica", size: 15)
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.center
        view.addSubview(messageLabel)

        navigationItem.titleView = searchText
        indicator.center = view.center
        view.addSubview(indicator)
        championsTable.estimatedRowHeight = championsTable.rowHeight
        championsTable.rowHeight = UITableViewAutomaticDimension
        reset()
        if summoner?.id == nil {
            let result: [Player] = (try! context.fetch(fetchPlayersRequest())) as! [Player]
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if showAlert {
            showAlert = false
            let alertController = UIAlertController(title: "No Favorite", message: "Tap the star icon to favorite your summoner", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
            
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        tryToRateApp()
    }
    
    func setUpSearchBar() {
        searchText.delegate = self
        searchText.placeholder = "Enter the Summoner's name"
        searchText.contentHorizontalAlignment = .center
        searchText.contentVerticalAlignment = .center
        searchText.borderStyle = .roundedRect
        searchText.font = UIFont(name: "Helvetica", size: 14)
        searchText.autocorrectionType = .no
        searchText.spellCheckingType = .no
        searchText.clearButtonMode = .whileEditing
        searchText.textAlignment = .center
        searchText.returnKeyType = .search
        searchText.enablesReturnKeyAutomatically = true
        
        let rightView = UIView()
        
        rightView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let button = UIButton(frame: CGRect(x: -1, y: 2, width: 14, height: 14))
        button.setBackgroundImage(UIImage(named: "clock"), for: UIControlState())
        button.addTarget(self, action: #selector(LOLSelfViewController.recentSearch), for: UIControlEvents.touchUpInside)
        rightView.addSubview(button)
        searchText.rightViewMode = UITextFieldViewMode.unlessEditing
        searchText.rightView = rightView
    }
    
    func reset() {
        championsTable.allowsSelection = true
        segmentBar.setWidth(0, forSegmentAt: 1)
        segmentBar.setEnabled(true, forSegmentAt: 1)
        segmentBar.isHidden = true
        favoriteButton.isHidden = true
        favoriteButton.setImage(UIImage(named: "star"), for: UIControlState())
        rankLabel.isHidden = true
        rankLabel.textColor = UIColor.black
        averageStatus.isHidden = true
        winRate.isHidden = true
        imageView.isHidden = true
        searchSummonerButton.isEnabled = true
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
        searchSummonerButton.isEnabled = false
        indicator.startAnimating()
    }
    
    // MARK: - Button Action
    @IBAction func segmentedControlActionChanged(_ sender: UISegmentedControl) {
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
        else if segmentBar.selectedSegmentIndex == 3 {
            FIRAnalytics.logEvent(withName: "trending_clicked" , parameters: [
                "region": region as NSObject
                ])

            let tvc = self.storyboard?.instantiateViewController(withIdentifier: "TrendingViewController") as? TrendingViewController
            self.navigationController?.pushViewController(tvc!, animated: true)
            
        }
        else {
            
            let tvc = self.storyboard?.instantiateViewController(withIdentifier: "CurrentGameViewController") as? CurrentGameViewController
            tvc?.summoner = self.summoner
            self.navigationController?.pushViewController(tvc!, animated: true)
        }
    }
    
    @IBAction func searchSummonerBarAction(_ sender: UIBarButtonItem) {
        performAction()
    }
    
    func recentSearch() {
        FIRAnalytics.logEvent(withName: "recent_search_clicked", parameters: [
            "region": region as NSObject
            ])
        let tvc = self.storyboard?.instantiateViewController(withIdentifier: "RecentSearchesViewController") as? RecentSearchesViewController
        self.navigationController?.pushViewController(tvc!, animated: true)
    }
    
    @IBAction func favorite(_ sender: UIButton) {

        if isFavorite() {
            
            favoriteButton.setImage(UIImage(named: "star"), for: UIControlState())
            deleteMeCoreData()
        }
        else {
            deleteMeCoreData()
            
            FIRAnalytics.logEvent(withName: "favorite_clicked", parameters: [
                "region": region as NSObject
                ])
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            }
            
            let ent = NSEntityDescription.entity(forEntityName: "Me", in: context)
            let me = Me(entity: ent!, insertInto: context)
            me.name = summoner!.name
            me.id = summoner!.id as NSNumber?
            me.region = region
            me.date = Date()
            me.homePage = 1
            do {
                try context.save()
                favoriteButton.setImage(UIImage(named: "full star"), for: UIControlState())
            } catch _ {
            }

        }
    }
    
    private func createAndLoadAds() {
        
        googleBannerView.adUnitID = AdMobAdUnitID
        googleBannerView.adSize = kGADAdSizeSmartBannerPortrait
        googleBannerView.delegate = self
        googleBannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [testDevice]
        googleBannerView.load(request)
 
        interstitial = GADInterstitial(adUnitID: AdMobAdUnitID)
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        interstitial.load(request)
    }

    
    func isFavorite() -> Bool {
        let result: [Me] = (try! context.fetch(fetchMeRequest())) as! [Me]
        if !result.isEmpty {
            if (result.first?.id)!.stringValue == (summoner?.id)!.description && (result.first?.region)! == region {
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
            
            let playersData = (try! context.fetch(fetchRequest)) as! [Player]
            var found = false
            for player in playersData {
                if uniformName(player.name!) == uniformName(searchText.text!) && player.region == region {
                    found = true
                    let obj:NSDictionary = ["name":player.name!, "id":player.id!]
                    player.date = Date()
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
            searchSummonerButton.isEnabled = true
        }
    }
    
    // MARK: - League of Lengends API
    func getRecentGamesInfo(_ summonerId: CLong) {
        let url = URL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.3/game/by-summoner/\(summonerId)/recent?api_key=\(api_key)")
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
                                    if let entries = resultDict["games"] as? NSArray {
                                        for entry in entries {
                                            let game:GameDto = GameDto(entry: entry as! NSDictionary)
                                            self.recentGames.append(game)
                                            self.recentGames.sort(by: { (c1:GameDto, c2:GameDto) -> Bool in
                                                return c1.createDate.int64Value > c2.createDate.int64Value
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
        }) 
        task.resume()
    }
    
    func getChampionRankInfo(_ summonerId: CLong) {
        let url = URL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.3/stats/by-summoner/\(summonerId)/ranked?season=SEASON2016&api_key=\(api_key)")
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if(error == nil) {
                    do {
                        let object = try JSONSerialization.jsonObject(with: data!, options: [])
                        if let resultDict = object as? NSDictionary {
                            if let entries = resultDict["champions"] as? NSArray {
                                for entry in entries {
                                    let rankChampion:ChampionStatus = ChampionStatus(entry: entry as! NSDictionary)
                                    if rankChampion.id != 0 {
                                        self.champions.append(rankChampion)
                                        self.champions.sort(by: { (c1:ChampionStatus, c2:ChampionStatus) -> Bool in
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
        }) 
        task.resume()
    }
    
    func getChampionMastery(_ summonerId: CLong) {
        let url = URL(string: "https://\(region).api.pvp.net/championmastery/location/\(platformMap[region]!)/player/\(summonerId)/champions?api_key=\(api_key)")
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if(error == nil) {
                    do {
                        let object = try JSONSerialization.jsonObject(with: data!, options: [])
                        if let entries = object as? NSArray {
                            for entry in entries {
                                let championMastery:ChampionMasteryDTO = ChampionMasteryDTO(data: entry as! NSDictionary)
                                self.championMastery.append(championMastery)
                                self.championMastery.sort(by: { (c1:ChampionMasteryDTO, c2:ChampionMasteryDTO) -> Bool in
                                    return c1.championPoints > c2.championPoints
                                })
                                self.championsTable.reloadData()
                            }
                        }
                    } catch {}
                }
            })
        }) 
        task.resume()
    }
    
    
    func getRankInfo(_ summonerId: CLong) {
        let url = URL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v2.5/league/by-summoner/\(summonerId)/entry?api_key=\(api_key)")
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! HTTPURLResponse? {
                            self.indicator.stopAnimating()
                            self.searchSummonerButton.isEnabled = true
                            
                            switch(httpReponse.statusCode) {
                                
                            case 200:
                                let object = try JSONSerialization.jsonObject(with: data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    if let entries = resultDict["\(summonerId)"] as? NSArray {
                                        self.rankInfo = RankInfo(data: entries[0] as! NSDictionary)
                                    }
                                }
                            case 404:
                                self.rankLabel.text = "Unranked"
                                self.rankLabel.isHidden = false
                                self.segmentBar.setEnabled(false, forSegmentAt: 1)
                                self.segmentBar.setWidth(0.1, forSegmentAt: 1)
                                self.favoriteButton.isHidden = false
                                self.segmentBar.isHidden = false
                                if self.isFavorite() {
                                    self.favoriteButton.setImage(UIImage(named: "full star"), for: UIControlState())
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
        }) 
        task.resume()
    }
    
    func getSummonerId(_ summonerName: String) {
        let urlSummonerName: String = summonerName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let trimmedSummonerName = summonerName.replacingOccurrences(of: " ", with: "")
        
        let url = URL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.4/summoner/by-name/\(urlSummonerName)?api_key=\(api_key)")
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if(error == nil) {
                    do {
                        if let httpReponse = reponse as! HTTPURLResponse? {
                            self.indicator.stopAnimating()
                            self.searchSummonerButton.isEnabled = true
                            
                            switch(httpReponse.statusCode) {
                            case 200:
                                let object = try JSONSerialization.jsonObject(with: data!, options: [])
                                if let resultDict = object as? NSDictionary {
                                    if let dataSet = resultDict.object(forKey: trimmedSummonerName.lowercased()) as? NSDictionary {
                                        self.summoner = Summoner(data: dataSet)
                                        let context = self.context
                                        let ent = NSEntityDescription.entity(forEntityName: "Players", in: context)
                                        let nPlayer = Player(entity: ent!, insertInto: context)
                                        nPlayer.name = self.searchText.text!
                                        nPlayer.id = self.summoner?.id as NSNumber?
                                        nPlayer.region = region
                                        nPlayer.date = Date()
                                        
                                        do {
                                            try context.save()
                                        } catch _ {
                                        }
                                    }
                                }
                            case 404:
                                self.rankLabel.text = "Not Found"
                                self.rankLabel.textColor = UIColor.red
                                self.rankLabel.isHidden = false
                                self.segmentBar.isHidden = true
                                self.favoriteButton.isHidden = true
                                
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
    
    func uniformName(_ summonerName: String) -> String {
        return summonerName.replacingOccurrences(of: " ", with: "").lowercased()
    }
    
    func showReponseMessage(_ message: String) {
        messageLabel.text = message
        indicator.stopAnimating()
        messageLabel.isHidden = false
    }
    
    // MARK: - UITableViewDataSource
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "champion"
        static let ReuseMatchCellIdentifer = "match"
        static let ReuseMasteryCellIdentifer = "mastery"
        static let MatchDetailIdentifier = "matchDetail"
        static let BorderColor = "607D8B"
        static let TitleFont = UIFont(name: "Helvetica-Bold", size: 18)
        static let DetailFont = UIFont(name: "Helvetica", size: 16)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentBar.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseMatchCellIdentifer) as! RecentGameTableViewCell?
            cell?.game = recentGames[(indexPath as NSIndexPath).row]
            cell?.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).cgColor
            cell?.layer.borderWidth = 1.0
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as! ChampionTableViewCell?
            cell?.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).cgColor
            cell?.layer.borderWidth = 1.0
            cell?.champion = champions[(indexPath as NSIndexPath).row]
            return cell!
        case 2:
            fallthrough
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseMasteryCellIdentifer) as! ChampionMasteryTableViewCell?
            cell?.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).cgColor
            cell?.layer.borderWidth = 1.0
            cell?.mastery = championMastery[(indexPath as NSIndexPath).row]
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentBar.selectedSegmentIndex {
        case 0: return recentGames.count
        case 1: return champions.count
        case 2: return championMastery.count
        default: return 0
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        discardKeyboard()
    }
    
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performAction()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchText.endEditing(true)
    }
    
    func toggleAddButton(_ text: String) {
        if text.isEmpty {
            searchSummonerButton.isEnabled = false
        }
        else {
            searchSummonerButton.isEnabled = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == searchText {
            let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            toggleAddButton(text)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchSummonerButton.isEnabled = false
        return true
    }
    
    // MARK: - GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        bannerView.isHidden = false
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    func adView(_ bannerView: GADBannerView!,
                didFailToReceiveAdWithError error: GADRequestError!) {
        bannerView.alpha = 1
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 0
        })
        bannerView.isHidden = true
    }
    
    func showRateAppAlert() {
        let alert = UIAlertController(title: "Rate \(APP_NAME)", message: "If you enjoy using \(APP_NAME), would you mind taking a moment to rate it? It wouldn't take more than a minute. Thanks for your support!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Rate It Now", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id\(APP_ID)")!)
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Remind me later", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(0, forKey: "numLaunches")
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")       // Hide the Alert
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tryToRateApp() {
        let neverRate = UserDefaults.standard.bool(forKey: "neverRate")
        let numLaunches = UserDefaults.standard.integer(forKey: "numLaunches") + 1
        if (!neverRate && (numLaunches >= minNumberOfSessions))
        {
            showRateAppAlert()
        }
        UserDefaults.standard.set(numLaunches, forKey: "numLaunches")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        discardKeyboard()
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.MatchDetailIdentifier:
                let cell = sender as? RecentGameTableViewCell
                let seguedToDetail = segue.destination as? MatchViewController
                guard let matchId = cell?.game?.gameId else { return }
                guard let fellowPlayers = cell?.game?.fellowPlayers else { return }
                let matchDetail = (fellowPlayers, matchId, (summoner?.name)!, (summoner?.id)!)
                seguedToDetail?.matchInit = matchDetail
                
            default: break
            }
        }
    }
}
