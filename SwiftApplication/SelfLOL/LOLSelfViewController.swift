//
//  LOLSelfViewController.swift
//  SelfLOL
//
//  Created by Lit Wa Yuen on 10/17/15.
//  Copyright © 2015 lit.wa.yuen. All rights reserved.
//

import UIKit

class LOLSelfViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var championsTable: UITableView!
    @IBOutlet weak var summonerNameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    var image: UIImage? {
        get{
            return imageView.image
        }
        set{
            imageView.image = newValue
            if let constrainedView = imageView {
                if let newImage = newValue {
                    aspectRatioConstraint = NSLayoutConstraint(
                        item: constrainedView,
                        attribute: .Width,
                        relatedBy: .Equal,
                        toItem: constrainedView,
                        attribute: .Height,
                        multiplier: newImage.aspectRatio,
                        constant: 0)
                }
                else{
                    aspectRatioConstraint = nil
                }
            }
        }
    }
    
    var aspectRatioConstraint: NSLayoutConstraint?{
        willSet{
            if let existingConstraint = aspectRatioConstraint {
                view.removeConstraint(existingConstraint)
            }
        }
        didSet{
            if let newConstraint = aspectRatioConstraint {
                view.addConstraint(newConstraint)
            }
        }
    }
    var rankInfo: RankInfo? {
        didSet{
            image = rankInfo?.image
            rankLabel.text = "\(rankInfo!.tier) \(rankInfo!.entry!.division)"
        }
    }

    var summoner: Summoner? {
        didSet{
            getRankInfo(summoner!.id)
            getChampionRankInfo(summoner!.id)

        }
    }
    
    var champions = [ChampionStatus]()
    var averageChampion: ChampionStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        championsTable.estimatedRowHeight = championsTable.rowHeight
        championsTable.rowHeight = UITableViewAutomaticDimension
        championsTable.dataSource = self
        championsTable.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchSummoner(sender: UIButton) {
        if summonerNameTextField.text != nil && summonerNameTextField.text != "" {
            champions.removeAll()
            getSummonerId(summonerNameTextField.text!)
        }
    }
    
    func getChampionRankInfo(summonerId: NSNumber) {
        let url = NSURL(string: "https://na.api.pvp.net/api/lol/na/v1.3/stats/by-summoner/\(summonerId)/ranked?season=SEASON2015&api_key=b40a6c35-4c98-4c9b-b034-76ef6be36ae2")
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

    
    func getRankInfo(summonerId: NSNumber) {
        let url = NSURL(string: "https://na.api.pvp.net/api/lol/na/v2.5/league/by-summoner/\(summonerId)/entry?api_key=b40a6c35-4c98-4c9b-b034-76ef6be36ae2")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let resultDict = object as? NSDictionary {
                            if let entries = resultDict["\(summonerId)"] as? NSArray {
                                self.rankInfo = RankInfo(data: entries[0] as! NSDictionary)

                            }

                        }
                    } catch {}
                }
            })
        }
        task.resume()
    }
    
    func getSummonerId(summonerName: String) {
        let url = NSURL(string: "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/\(summonerName)?api_key=b40a6c35-4c98-4c9b-b034-76ef6be36ae2")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let resultDict = object as? NSDictionary {
                            if let dataSet = resultDict.objectForKey(summonerName.lowercaseString) as? NSDictionary {
                                self.summoner = Summoner(data: dataSet)
                                
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
        static let ReuseCellIdentifier = "champion"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! ChampionTableViewCell?
        cell?.champion = champions[indexPath.row]
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return champions.count
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RankInfo {
    var image: UIImage? {
        let rank = "\(tier)_\(entry!.division)".lowercaseString
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
        if let image = UIImage(named: championsMap[id]!){
            return image
        }
        else {
            return UIImage(named: "provisional")
        }
    }
}



extension UIImage{
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}
