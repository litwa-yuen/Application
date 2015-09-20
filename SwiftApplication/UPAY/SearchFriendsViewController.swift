//
//  SearchFriendsViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 9/17/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import UIKit
import CoreData
import ContactsUI

class SearchFriendsViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    var friendList = [String]()
    var filteredFriendList = [String]()
    var searchController: UISearchController!
    let store = CNContactStore()
    // MARK: - NSFetchedResultsControllerDelegate
    let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        getContacts()
        
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
    
    func getContacts() {
        let store = CNContactStore()
        
        store.requestAccessForEntityType(.Contacts) { (success, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let predicate = CNContact.predicateForContactsInContainerWithIdentifier(store.defaultContainerIdentifier())
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName)]
            
            do {
                let contacts = try store.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
                
                
                for contact in contacts {
                    
                    let fullName = CNContactFormatter.stringFromContact(contact, style: .FullName) ?? "No Name"

                    self.friendList.append(fullName)
                    self.tableView.reloadData()
                    
                }
                
            } catch _ {
                print("An error occured.")
            }
        }
        
    }
    
    @IBAction func addFriend(sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Add Friend",
            message: "Please enter a friend name ...",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Cancel)
            { (action) in
                // do nothing
        }
        alert.addAction(cancelAction)
        
        let addFriendAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (action) -> Void in
            if let tf = alert.textFields?.first as UITextField! {
                if !self.friendList.isEmpty {
                    self.friendList.insert(tf.text!, atIndex: 1)
                }
                else {
                    self.friendList.append(tf.text!)
                }
                self.tableView.reloadData()
            }
        }
        alert.addAction(addFriendAction)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "friend name"
        }
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func addFriendDatabase(name: String) {
        let context = self.context
        let ent = NSEntityDescription.entityForName("Participants", inManagedObjectContext: context)
        let nParticipant = Participants(entity: ent!, insertIntoManagedObjectContext: context)
        nParticipant.name = name
        let uuid = NSUUID().UUIDString
        nParticipant.id = uuid
        do {
            try context.save()
        } catch _ {
        }
        
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
