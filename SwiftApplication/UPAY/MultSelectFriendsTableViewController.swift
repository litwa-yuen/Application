//
//  MultSelectFriendsTableViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/16/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase

class MultSelectFriendsTableViewController: UITableViewController {

    @IBOutlet var friendsTableView: UITableView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    let user: FIRUser = FIRAuth.auth()!.currentUser!
    let database = FIRDatabase.database().reference()

    
    var items: [User] = []
    var selectedUsers: [Int:User] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        retrieveFriends()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveFriends () {
        let groups = database.child("users/\(user.uid)/friends")
        
        groups.queryOrderedByKey().observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
            let newUser = User(snapshot: snapshot)
            guard self.items.map({$0.uid}).index(of: newUser.uid) == nil else { return }
            
            switch (newUser.type) {
            case .FRIEND:
                self.items.append(newUser)
                self.friendsTableView.reloadData()
            default: break
                
                
            }
            
        }
        
        groups.queryOrderedByKey().observe(.childChanged) { (snapshot: FIRDataSnapshot) in
            
            let newUser = User(snapshot: snapshot)
            guard self.items.map({$0.uid}).index(of: newUser.uid) == nil else { return }
            
            switch (newUser.type) {
            case .FRIEND:
                self.items.append(newUser)
                self.friendsTableView.reloadData()
            default: break
                
                
            }
            
        }
        
    }
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
            dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedUsers.removeValue(forKey: indexPath.row)
        if selectedUsers.isEmpty {
            nextButton.isEnabled = false
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nextButton.isEnabled = true
        selectedUsers[indexPath.row] = items[indexPath.row]
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }

    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "friend"
        static let CreateGroupIdentifier = "createGroup"

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as UITableViewCell?
        cell?.textLabel?.text = items[indexPath.row].name
        
        return cell!
    }

    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.CreateGroupIdentifier:
                let seguedToDetail = segue.destination as? CreateGroupTableViewController
                seguedToDetail?.items = Array(selectedUsers.values)

               
            default: break
            }
        }

    }
    

}
