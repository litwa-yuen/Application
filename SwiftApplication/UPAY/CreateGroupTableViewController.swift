//
//  CreateGroupTableViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/16/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupTableViewController: UITableViewController, UITextFieldDelegate {

    
    @IBOutlet weak var createGroupButton: UIBarButtonItem!
    
    let currentUser: FIRUser = FIRAuth.auth()!.currentUser!
    let database = FIRDatabase.database().reference()

    var items: [User] = []
    var groupName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        createGroupButton.isEnabled = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func backAction(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func createGroupAction(_ sender: UIBarButtonItem) {
        createGroup()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return items.count
        }
        else {
            return 1
        }
    }

    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "participant"
        static let GroupNameIdentifier = "groupName"

    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier, for: indexPath)
            cell.textLabel?.text = items[indexPath.row].name
            return cell

        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.GroupNameIdentifier) as! GroupNameTextFieldTableViewCell
            cell.groupNameTextField.delegate = self // theField is your IBOutlet UITextfield in your custom cell
            return cell
        }
        // Configure the cell...

    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        groupName = textField.text!
        createGroup()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        groupName = textField.text!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        groupName = text
        if !text.isEmpty{
            createGroupButton.isEnabled = true
        } else {
            createGroupButton.isEnabled = false
        } 
        return true
    }
    
    func createGroup() {
        //create group
        let groupId = database.child("groups").childByAutoId().key
        database.child("groups").child(groupId).updateChildValues(["name": groupName, "createDate": NSDate().timeIntervalSince1970,
                                                                   "numOfMember": items.count+1])
        
        database.child("groups").child(groupId).child("members").childByAutoId().updateChildValues(["name" : currentUser.displayName!, "uid": currentUser.uid])
        
        for user in items {
            database.child("groups").child(groupId).child("members").childByAutoId().updateChildValues(["name" : user.name, "uid": user.uid])
            database.child("users").child(user.uid).child("groups").childByAutoId().updateChildValues(["name": groupName,"id":groupId])
        }
        database.child("users").child(currentUser.uid).child("groups").childByAutoId().updateChildValues(["name": groupName, "id":groupId])
        dismiss(animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
