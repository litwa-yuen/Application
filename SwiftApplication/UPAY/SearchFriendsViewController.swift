//
//  SearchFriendsViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/11/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase


class SearchFriendsViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    var items: [User] = []
    
    let database = FIRDatabase.database().reference()
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var friendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        friendTableView.dataSource = self
   
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "hit"
        static let FriendIdentifier = "friend"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as UITableViewCell?
        cell?.textLabel?.text = items[indexPath.row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func searchFriend(email: String) {
        let friends = database.child("users")
        
        friends.queryOrdered(byChild: "email").queryEqual(toValue: "\(email)").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
            self.items.append(User(snapshot: snapshot ))
            
            self.friendTableView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFriend(email: searchBar.text!)
    }

    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.FriendIdentifier:
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
