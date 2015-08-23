//
//  TransactionViewController.swift
//  UPAY
//
//  Created by Lit Wa Yuen on 8/22/15.
//  Copyright (c) 2015 CS320. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableFriends: UITableView!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    @IBAction func addToQueue(sender: UIBarButtonItem) {
        if amountTextField?.text == nil || amountTextField?.text == "" {
            
            friendMgr.addFriend(searchTextField.text, amount: 0.0)
        }
        else {
            friendMgr.addFriend(searchTextField.text, amount: ( amountTextField.text as NSString).doubleValue)
        }
        self.view.endEditing(true)
        amountTextField.text = nil
        searchTextField.text = nil
        tableFriends.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        tableFriends.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    
 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendMgr.friends.count
    }
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "transFriend"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let friend = friendMgr.friends[indexPath.row]
        cell.textLabel?.text = friend.name
        cell.detailTextLabel?.text = "$\(friend.amount)"
        
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            friendMgr.friends.removeAtIndex(indexPath.row)
            tableFriends.reloadData()
        }
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
