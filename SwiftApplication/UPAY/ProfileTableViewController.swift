//
//  ProfileTableViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/12/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var nameTableCell: UITableViewCell!
    @IBOutlet weak var ResponseTableCell: UITableViewCell!
    @IBOutlet weak var friendTableCell: UITableViewCell!
    
    let currentUser: FIRUser = FIRAuth.auth()!.currentUser!
    let database = FIRDatabase.database().reference()

    var friendType: FriendType = FriendType.NEUTRAL {
        didSet {
            setUpButton()
        }
    }
    
    @IBOutlet weak var requestButton: UIButton!
    var hitUser: User? {
    
        didSet {
            retrieveFriendType()
        }
    }
    let sectionMap = [1, 1, 1]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        nameTableCell.textLabel?.text = hitUser?.name
    }
    
    func retrieveFriendType() {
       
        
        let friends = database.child("users").child(currentUser.uid).child("friends").child((hitUser?.uid)!).child("type")
        
        friends.observe(.value) { (snapshot: FIRDataSnapshot) in
            if snapshot.value is NSNull {
                if self.currentUser.uid == self.hitUser?.uid {
                    self.friendType = FriendType.SELF
                }
                else {
                    self.friendType = FriendType.NEUTRAL
                }
            }
            else {
                switch((snapshot.value as! String)) {
                case "FRIEND", "REQUEST", "RESPONSE", "FRIEND":
                    self.friendType = FriendType(rawValue: (snapshot.value as! String))!
                default:
                    if self.currentUser.uid == self.hitUser?.uid {
                        self.friendType = FriendType.SELF
                    }
                    else {
                        self.friendType = FriendType.NEUTRAL
                    }
                }
            }
        }
    }

    @IBAction func confirmAction(_ sender: UIButton) {
        database.child("users").child(currentUser.uid).child("friends")
            .child((hitUser?.uid)!).updateChildValues(["type":FriendType.FRIEND.rawValue])
        database.child("users").child((hitUser?.uid)!).child("friends")
            .child(currentUser.uid).updateChildValues(["type":FriendType.FRIEND.rawValue])
        retrieveFriendType()
    }
    
    
    @IBAction func declineAction(_ sender: UIButton) {
        removeEntries()
        retrieveFriendType()
    }

    @IBAction func addAction(_ sender: UIButton) {
        switch friendType {
        case .REQUEST, .FRIEND:
            removeEntries()
        case .NEUTRAL:
            sendFriendRequest()
        default: break
        }
        
    }
    
    func setUpButton() {
        switch friendType {
        case .NEUTRAL:
            ResponseTableCell.isHidden = true
            friendTableCell.isHidden = false
            requestButton.setTitle("Add", for: .normal)
        case .FRIEND:
            ResponseTableCell.isHidden = true
            friendTableCell.isHidden = false
            requestButton.setTitle("Unfriend", for: .normal)
        case .REQUEST:
            ResponseTableCell.isHidden = true
            friendTableCell.isHidden = false
            requestButton.setTitle("Cancel Request", for: .normal)
        case .RESPONSE:
            friendTableCell.isHidden = true
            ResponseTableCell.isHidden = false
        case .SELF:
            friendTableCell.isHidden = true
            ResponseTableCell.isHidden = true

        }
    }
    
    func sendFriendRequest() {
        database.child("users").child(currentUser.uid).child("friends")
            .child((hitUser?.uid)!).setValue(["name": (hitUser?.name)!,"uid": (hitUser?.uid)!, "type":FriendType.REQUEST.rawValue])
        database.child("users").child((hitUser?.uid)!).child("friends")
            .child(currentUser.uid).setValue(["name": (currentUser.displayName)!,"uid": currentUser.uid, "type":FriendType.RESPONSE.rawValue])
        retrieveFriendType()
    }
    
    func removeEntries() {
        database.child("users").child(currentUser.uid).child("friends")
            .child((hitUser?.uid)!).removeValue()
        database.child("users").child((hitUser?.uid)!).child("friends")
            .child(currentUser.uid).removeValue()
        retrieveFriendType()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionMap.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sectionMap[section]
    }
    
    
    
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
