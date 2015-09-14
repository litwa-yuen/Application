//
//  ParticipantsViewController.swift
//  UPAY
//
//  Created by Lit Wa Yuen on 9/10/15.
//  Copyright (c) 2015 CS320. All rights reserved.
//

import UIKit
import CoreData

class ParticipantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var participantsTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var frc: NSFetchedResultsController = NSFetchedResultsController()
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        frc = NSFetchedResultsController(fetchRequest: friendFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
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
        var fetchRequest = NSFetchRequest(entityName: "Friends")
        friendData = context.executeFetchRequest(fetchRequest, error: nil) as! [Friends]
        for friend in friendData {
            let number = Int(friend.multiplier)
            friendMgr.addFriend(friend.name, amount: friend.amount, multiplier: number, desc: friend.desc )
        }
    }

    func deleteCoreData() {
        var friendData = [Friends]()
        var fetchRequest = NSFetchRequest(entityName: "Friends")
        friendData = context.executeFetchRequest(fetchRequest, error: nil) as! [Friends]
        for friend in friendData {
            context.deleteObject(friend)
        }
        context.save(nil)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        participantsTableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        frc = getFetchedResultsController()
        frc.delegate = self
        frc.performFetch(nil)
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
    
    // MARK: - Actions and Utilities
    
    @IBAction func clearAll(sender: UIBarButtonItem) {
        deleteCoreData()
        refresh()
    }
    
    func refresh() {
        friendMgr.friends.removeAll()
        friendMgr.summary.removeAll()
        fetchData()
        friendMgr.evalute()
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        averageLabel.text = "Average: \(formatter.stringFromNumber(friendMgr.average())!)"
        totalLabel.text = "Total: \(formatter.stringFromNumber(friendMgr.total())!)"

        participantsTableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "Participant"
        static let DetailIdentifier = "detail"
        static let SummaryIdentifier = "showSummary"
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
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let friend = frc.objectAtIndexPath(indexPath) as! Friends
        cell.textLabel?.text = "\(friend.name) (\(friend.multiplier))"
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        cell.detailTextLabel?.text = formatter.stringFromNumber(friend.amount)!
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject: NSManagedObject = frc.objectAtIndexPath(indexPath) as! NSManagedObject
        context.deleteObject(managedObject)
        context.save(nil)
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
