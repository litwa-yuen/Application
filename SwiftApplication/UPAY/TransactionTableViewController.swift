//
//  TransactionTableViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 11/11/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import CoreData
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

class TransactionTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var action: Action?
    var friend: Friends?
    
    var currentUser: FIRUser = FIRAuth.auth()!.currentUser!

    
    var friendName: String = ""{
        didSet{
            nameLabel?.text = friendName
        }
    }
    
    var friendId: String = ""
    
    var newParticipant = ("","") {
        didSet {
            friendName = newParticipant.0
            friendId = newParticipant.1
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var nFriend: Friends? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextField.delegate = self
        amountTextField.delegate = self
        nameLabel?.text = friendName
        
        if let f = friend {
            nameLabel.text = f.name
            amountTextField.text = f.amount.description
            descriptionTextField.text = f.desc
        }
        if let a = action {
            nameLabel.text = a.name
            descriptionTextField.text = a.description
            amountTextField.text = a.amount.description

        }

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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        newFriend()
        self.view.endEditing(true)
        _ = self.navigationController?.popToRootViewController(animated: true)

    }
    
    func newFriend() {
        if action !=  nil {
            action?.ref?.updateChildValues(["amount": (amountTextField.text! as NSString).doubleValue, "name":nameLabel.text ?? "", "description": descriptionTextField.text ?? "", "modifiedDate":NSDate().timeIntervalSince1970, "modifiedBy":currentUser.uid])
        }
        else {
            if friend == nil {
                let ent = NSEntityDescription.entity(forEntityName: "Friends", in: context)
                friend = Friends(entity: ent!, insertInto: context)
                friend?.identifier = friendId
            }
            
            friend?.name = nameLabel.text!
            
            if amountTextField?.text == nil || amountTextField?.text == "" {
                friend?.amount = 0.0
            }
            else {
                friend?.amount = (amountTextField.text! as NSString).doubleValue
            }
            
            friend?.multiplier = 1
            
            if descriptionTextField.text == nil {
                friend?.desc = ""
            }
            else {
                friend?.desc = descriptionTextField.text!
            }
            do {
                try context.save()
            } catch _ {
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
