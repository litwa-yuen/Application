//
//  GroupsViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/4/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase

class GroupsViewController: UIViewController, UITableViewDataSource {

    var user: FIRUser = FIRAuth.auth()!.currentUser!
    var items: [Group] = []

    
    @IBOutlet weak var GroupTableView: UITableView!
    let database = FIRDatabase.database().reference()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveGroups()
      
        // Do any additional setup after loading the view.
        
        GroupTableView.dataSource = self
        
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        GroupTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "group"
        static let ActionIdentifier = "action"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as UITableViewCell?
        cell?.textLabel?.text = items[indexPath.row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteGroup(group: items[indexPath.row])
            items.remove(at: indexPath.row)
            GroupTableView.reloadData()
        default:
            break
        }
    }
    
    func deleteGroup(group: Group) {
        let checkMember = database.child("groups/\(group.groupId)/numOfMember")
        var set = false
        checkMember.observe(.value) { (snapshot: FIRDataSnapshot) in
            let numOfMember = snapshot.value as? Int ?? 1
            if !set {
                if numOfMember == 1 {
                    self.database.child("groups").child("\(group.groupId)").removeValue()
                }
                else {
                    checkMember.setValue(numOfMember-1)
                }
                set = true
            }
            
        }
        group.ref?.removeValue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func retrieveGroups () {
        let groups = database.child("users/\(user.uid)/groups")
        
        groups.queryOrderedByKey().observe(.childAdded) { (snapshot: FIRDataSnapshot) in
           
            let newGroup = Group(snapshot: snapshot)
            guard self.items.map({$0.key}).index(of: newGroup.key) == nil else { return }
            self.items.append(newGroup)
            
            self.GroupTableView.reloadData()
        }

    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ActionIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = GroupTableView.indexPath(for: cell!) {

                    let seguedToDetail = segue.destination as? TransactionActionsViewController
                    seguedToDetail?.groupId = items[indexPath.row].groupId
                    seguedToDetail?.name = items[indexPath.row].name
                    
                    GroupTableView.deselectRow(at: indexPath, animated: false)

                    
                }
            default: break
            }
        }

    }
 

}
