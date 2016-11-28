//
//  FriendsViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/11/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDataSource {
    
    
    var user: FIRUser = FIRAuth.auth()!.currentUser!

    var items: [User] = []
    
    let database = FIRDatabase.database().reference()

    @IBOutlet weak var friendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveFriends()
        definesPresentationContext = true
        friendTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
        
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        items.removeAll()
        retrieveFriends()
        friendTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "friend"
        static let ProfileIdentifier = "profile"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as! FriendTableViewCell
        cell.hitUser = items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func retrieveFriends () {
        let groups = database.child("users/\(user.uid)/friends")
        
        groups.queryOrderedByKey().observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
            let newUser = User(snapshot: snapshot)
            guard self.items.map({$0.uid}).index(of: newUser.uid) == nil else { return }
            
            switch (newUser.type) {
            case .FRIEND, .RESPONSE:
                    self.items.append(newUser)
                    self.friendTableView.reloadData()
            default: break
                
                
            }
            
        }
        
        groups.queryOrderedByKey().observe(.childChanged) { (snapshot: FIRDataSnapshot) in
            
            let newUser = User(snapshot: snapshot)
            guard self.items.map({$0.uid}).index(of: newUser.uid) == nil else { return }
            
            switch (newUser.type) {
            case .FRIEND, .RESPONSE:
                self.items.append(newUser)
                self.friendTableView.reloadData()
            default: break
                
                
            }
            
        }
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ProfileIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = friendTableView.indexPath(for: cell!) {
                    let seguedToDetail = segue.destination as? ProfileTableViewController
                    seguedToDetail?.hitUser = items[indexPath.row]
                    friendTableView.deselectRow(at: indexPath, animated: false)
                    
                    
                }
            default: break
            }
        }
    }
    

}
