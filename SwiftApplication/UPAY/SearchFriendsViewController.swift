//
//  SearchFriendsViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 9/17/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class SearchFriendsViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    var friendList = [String]()
    var filteredFriendList = [String]()
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            getFriendList()
            getUserInfo()
        }
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        // If we are using this same view controller to present the results
        // dimming it out wouldn't make sense.  Should set probably only set
        // this to yes if using another controller to display the search results.
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Facebook API
    func getFriendList() {
        
        let friendsRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/taggable_friends", parameters: ["fields":"id, name"])
        friendsRequest.startWithCompletionHandler({ (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let resultdict = result as? NSDictionary {
                    if let data = resultdict.objectForKey("data") as? NSArray {
                        for i in 0...data.count-1 {
                            if let valueDict = data[i] as? NSDictionary {
                                if let name = valueDict.objectForKey("name") as? String {
                                    self.friendList.append(name)
                                    self.tableView.reloadData()
                                }
                            }
                            
                        }
                    }
                }
            }
            
        })
        
    }
    
    func getUserInfo () {
        let meRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name"])
        meRequest.startWithCompletionHandler ({ (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let resultdict = result as? NSDictionary {
                    if let username = resultdict.objectForKey("name") as? String {
                        let displayName = username + " (You)"
                        self.friendList.append(displayName)
                        self.tableView.reloadData()
                    }
                }
            })
        })
    }
    

    // MARK: - Search Results Updating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchText!)
        let filterArray = (friendList as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredFriendList = searchText!.isEmpty ? friendList : filterArray as! [String]
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.searchController.active {
            return filteredFriendList.count
        }
        else {
            return friendList.count
        }
    }
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "friendCell"
        static let AddIdentifier = "add"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath)
        
        if self.searchController.active {
            cell.textLabel?.text = filteredFriendList[indexPath.row]
        }
        else {
            cell.textLabel?.text = friendList[indexPath.row]
        }
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.AddIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell!) {
                    let seguedToDetail = segue.destinationViewController as? TransactionViewController
                    
                    if searchController.active {
                        seguedToDetail?.friendName = filteredFriendList[indexPath.row]
                    }
                    else {
                        seguedToDetail?.friendName = friendList[indexPath.row]
                    }
                    
                }
            default: break
            }
        }
    }
    

}
