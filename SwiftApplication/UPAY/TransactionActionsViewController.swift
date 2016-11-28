//
//  TransactionActionsViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/9/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase


class TransactionActionsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var actionTableView: UITableView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    let database = FIRDatabase.database().reference()
    
    let groupDetail: UIButton = UIButton(frame:  CGRect(x: 0,y: 0,width: 280,height: 30))

    
    var groupId: String?{
        didSet{
            retrieveGroupDetail(groupId: groupId!)
        }
    }
    
    var name: String? {
        didSet{
            groupDetail.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            groupDetail.setTitleColor(UIColor.black, for: .normal)
            groupDetail.setTitleColor(UIColor.lightGray, for: .highlighted)

            groupDetail.setTitle(name, for: .normal)
        }
    }
    
    var items: [Action] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.titleView = groupDetail
        
        groupDetail.addTarget(self, action: #selector(TransactionActionsViewController.showGroupDetail), for: UIControlEvents.touchUpInside)
        refresh()
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "action"
        static let AddIdentifier = "add"
        static let DetailIdentifier = "detail"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as UITableViewCell?
        cell?.textLabel?.text = items[indexPath.row].name
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        cell?.detailTextLabel?.text = formatter.string(from: NSNumber(value: items[indexPath.row].amount))!
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func showGroupDetail(sender:UIButton!) {
        let tvc = self.storyboard?.instantiateViewController(withIdentifier: "GroupInfoTableViewController") as? GroupInfoTableViewController
        tvc?.groupId = groupId
        self.navigationController?.pushViewController(tvc!, animated: true)
    }

    
    func retrieveGroupDetail(groupId: String) {
        
        let members = database.child("groups/\(groupId)/members")
        members.queryOrderedByKey().observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            let member = User(snapshot: snapshot)
            friendMgr.addFriend(member.name, amount: 0.0, multiplier: 1, desc: "", identifier: member.uid)
            self.averageLabel.text = " Average: $\(friendMgr.average())"
            self.totalLabel.text = "Total: $\(friendMgr.total()) "
        }

        let actions = database.child("groups/\(groupId)/actions")
        
        actions.queryOrderedByKey().observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            let action = Action(snapshot: snapshot)
            self.items.append(action)
            friendMgr.addFriend(action.name, amount: action.amount, multiplier: 1, desc: action.description, identifier: action.createdBy)
            self.averageLabel.text = " Average: $\(friendMgr.average())"
            self.totalLabel.text = "Total: $\(friendMgr.total()) "
            self.actionTableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteAction(action: items[indexPath.row])
            items.remove(at: indexPath.row)
            averageLabel.text = " Average: $\(friendMgr.average())"
            totalLabel.text = "Total: $\(friendMgr.total()) "

            actionTableView.reloadData()
        default:
            break
        }
    }
    
    func deleteAction(action: Action) {
        friendMgr.removeAction(action: action)
        action.ref?.removeValue()
    }

    
    func refresh() {
        self.averageLabel.text = " Average: $0.00"
        self.totalLabel.text = "Total: $0.00 "
        friendMgr.friends.removeAll()
        friendMgr.summary.removeAll()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.AddIdentifier:
                
                let seguedToDetail = segue.destination as? AddTransactionTableViewController
                seguedToDetail?.groupId = groupId!
            case Storyboard.DetailIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = actionTableView.indexPath(for: cell!) {
                    let seguedToDetail = segue.destination as? DetailTableViewController
                    friendMgr.evalute()
                    seguedToDetail?.transDecs = items[indexPath.row].description
                    seguedToDetail?.title = items[indexPath.row].name
                    let id = items[indexPath.row].createdBy
                    seguedToDetail?.tranactions = friendMgr.friends[friendMgr.findFriend(identifier: id)].detail
                    seguedToDetail?.action = items[indexPath.row]
                    actionTableView.deselectRow(at: indexPath, animated: false)
                    
                }
                
            default: break
            }
        }
        
    }

}
