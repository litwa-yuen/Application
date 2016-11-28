//
//  GroupInfoTableViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 11/14/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase

class GroupInfoTableViewController: UITableViewController {
    
    let database = FIRDatabase.database().reference()

    var groupId: String?{
        didSet{
            retrieveGroupDetail(groupId: groupId!)
        }
    }
    
    var items: [User] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Members"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func retrieveGroupDetail(groupId: String) {
        let members = database.child("groups/\(groupId)/members")
        
        members.queryOrderedByKey().observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            let member = User(snapshot: snapshot)
            self.items.append(member)
            self.tableView.reloadData()
        }
    }
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "member"
        static let GroupFriend = "profit"
        static let GroupNameIdentifier = "name"
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        return cell

        
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
            case Storyboard.GroupFriend:
                let cell = sender as? UITableViewCell
                if let indexPath = tableView.indexPath(for: cell!) {
                    let seguedToDetail = segue.destination as? ProfileTableViewController
                    seguedToDetail?.hitUser = items[indexPath.row]
                    tableView.deselectRow(at: indexPath, animated: false)
                    
                    
                }
            default: break
            }
        }

    }
    

}
