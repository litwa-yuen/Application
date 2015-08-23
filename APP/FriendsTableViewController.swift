//
//  FriendsTableViewController.swift
//  UPAY
//
//  Created by Lit Wa Yuen on 8/22/15.
//  Copyright (c) 2015 CS320. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController, UITextFieldDelegate {
    
    var allFriendsArray = [FriendItem]()
    
    var searchText: String? = nil {
        didSet {
            searchTextField?.text = searchText
            allFriendsArray.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func refresh() {
        allFriendsArray += [FriendItem(name: "litwa", amount: 0.0)]
        allFriendsArray += [FriendItem(name: "kayin", amount: 0.0)]
        
        if searchText != nil && searchText != "" {
            
            allFriendsArray = allFriendsArray.filter({ (friend:FriendItem) -> Bool in
                var stringMatch = friend.name.rangeOfString(self.searchText!)
                return stringMatch != nil
            })
        }
        tableView.reloadData()
    }

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
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
        return allFriendsArray.count
    }

    private struct Storyboard {
        static let ReuseCellIdentifier = "friend"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let friend = allFriendsArray[indexPath.row]
        cell.textLabel?.text = friend.name
        cell.detailTextLabel?.text = "\(friend.amount)"
        

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
