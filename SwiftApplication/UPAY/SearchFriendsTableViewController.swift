//
//  SearchFriendsTableViewController.swift
//  UPAY
//
//  Created by Lit Wa Yuen on 9/11/15.
//  Copyright (c) 2015 CS320. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class SearchFriendsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var friendList:[String] = [String]()
    var filteredFriendList = [String]()
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        getFriendList()
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        tableView.tableHeaderView = resultSearchController.searchBar
        tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.resultSearchController.active {
            return filteredFriendList.count
        }
        else {
            return friendList.count
        }
    }
    
    func getFriendList() {
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            var friendsRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/taggable_friends", parameters: ["fields":"id, name"])
            friendsRequest.startWithCompletionHandler({ (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if let resultdict = result as? NSDictionary{
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
    }

    private struct Storyboard {
        static let ReuseCellIdentifier = "friendCell"
        static let AddIdentifier = "add"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath) as! UITableViewCell

        if self.resultSearchController.active {
            cell.textLabel?.text = filteredFriendList[indexPath.row]
        }
        else {
            cell.textLabel?.text = friendList[indexPath.row]
        }
        // Configure the cell...

        return cell
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredFriendList.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (friendList as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredFriendList = array as! [String]
        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.AddIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell!) {
                    let seguedToDetail = segue.destinationViewController as? TransactionViewController
                    if resultSearchController.active {
                        let name = filteredFriendList[indexPath.row] as String
                        seguedToDetail?.friendName = name
                    }
                    else {
                        let name = friendList[indexPath.row] as String
                        seguedToDetail?.friendName = name
                    }
                }
            default: break
            }
        }
    }

    

}
