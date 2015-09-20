//
//  ParticipantsViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 9/17/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import UIKit
import CoreData

class ParticipantsViewController: UIViewController, NSFetchedResultsControllerDelegate,
UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var participantsTableView: UITableView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    let context: NSManagedObjectContext = (UIApplication.sharedApplication()
        .delegate as! AppDelegate).managedObjectContext
    var frc: NSFetchedResultsController = NSFetchedResultsController()
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        frc = NSFetchedResultsController(fetchRequest: friendFetchRequest(),
            managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }
    
    func friendFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Friends")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return  fetchRequest
    }
    
    func fetchData() {
        var friendData = [Friends]()
        let fetchRequest = NSFetchRequest(entityName: "Friends")
        friendData = (try! context.executeFetchRequest(fetchRequest)) as! [Friends]
        for friend in friendData {
            let number = Int(friend.multiplier!)
            friendMgr.addFriend(friend.name, amount: friend.amount, multiplier: number, desc: friend.desc )
        }
    }
    
    func deleteCoreData() {
        var friendData = [Friends]()
        let fetchRequest = NSFetchRequest(entityName: "Friends")
        friendData = (try! context.executeFetchRequest(fetchRequest)) as! [Friends]
        for friend in friendData {
            context.deleteObject(friend)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        participantsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frc = getFetchedResultsController()
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch _ {
        }
        participantsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clearAll(sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Warning!",
            message: "Are you sure you want to delete all transactions",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Cancel)
            { (action) in
                // do nothing
        }
        alert.addAction(cancelAction)
        
        let clearAllAction = UIAlertAction(title: "Clear", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.deleteCoreData()
            self.refresh()
        }
        alert.addAction(clearAllAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func refresh() {
        friendMgr.friends.removeAll()
        friendMgr.summary.removeAll()
        fetchData()
        friendMgr.evalute()
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        averageLabel.text = "Average: \(formatter.stringFromNumber(friendMgr.average())!)"
        totalLabel.text = "Total: \(formatter.stringFromNumber(friendMgr.total())!)"
        
        participantsTableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "Participant"
        static let DetailIdentifier = "detail"
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRow = frc.sections?[section].numberOfObjects
        return numberOfRow!
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = frc.sections?.count
        return numberOfSections!
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath)
        let friend = frc.objectAtIndexPath(indexPath) as! Friends
        if friend.multiplier == 1 {
            cell.textLabel?.text = "\(friend.name)"
        }
        else {
            let broughtWith = (friend.multiplier) as! Int - 1
            cell.textLabel?.text = "\(friend.name) + \(broughtWith)"
        }
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        cell.detailTextLabel?.text = formatter.stringFromNumber(friend.amount)!
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject: NSManagedObject = frc.objectAtIndexPath(indexPath) as! NSManagedObject
        context.deleteObject(managedObject)
        do {
            try context.save()
        } catch _ {
        }
        refresh()
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.DetailIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = participantsTableView.indexPathForCell(cell!) {
                    let seguedToDetail = segue.destinationViewController as? DetailTableViewController
                    let nFriend: Friends = frc.objectAtIndexPath(indexPath) as! Friends
                    seguedToDetail?.friendData = nFriend
                }
            default: break
            }
        }
    }
    
    
}
