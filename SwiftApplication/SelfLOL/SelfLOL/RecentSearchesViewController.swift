//
//  RecentSearchesViewController.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 4/21/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import UIKit
import CoreData

class RecentSearchesViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var recentSearchTableView: UITableView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    
    let context: NSManagedObjectContext = (UIApplication.sharedApplication()
        .delegate as! AppDelegate).managedObjectContext
    var frc: NSFetchedResultsController = NSFetchedResultsController()
    
    func recentSearchFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Players")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return  fetchRequest
    }

    func getFetchedResultsController() -> NSFetchedResultsController {
        frc = NSFetchedResultsController(fetchRequest: recentSearchFetchRequest(),
                                         managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        frc = getFetchedResultsController()
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch _ {
        }

        recentSearchTableView.estimatedRowHeight = recentSearchTableView.rowHeight
        recentSearchTableView.rowHeight = UITableViewAutomaticDimension
        recentSearchTableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clear(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
  
        alert.addAction(UIAlertAction(
        title: "Clear Recent Searches", style: .Default) { (action) -> Void in
            self.deleteCoreData()
            })
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .Cancel)
        { (action) in
            // do nothing
            })
        alert.modalPresentationStyle = .Popover
        let ppc = alert.popoverPresentationController
        ppc?.barButtonItem = clearButton
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - UITableViewDelegate
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "recent"
        static let PlayerIdentifier = "player"
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
        let player = frc.objectAtIndexPath(indexPath) as! Player
        cell.textLabel?.text = "\(player.name!)"
        cell.detailTextLabel?.text = "(\((player.region?.uppercaseString)!))"
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
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        recentSearchTableView.reloadData()
    }
    
    func deleteCoreData() {
        var playersData = [Player]()
        let fetchRequest = NSFetchRequest(entityName: "Players")
        playersData = (try! context.executeFetchRequest(fetchRequest)) as! [Player]
        for player in playersData {
            context.deleteObject(player)
        }
        do {
            try context.save()
        } catch _ {
        }
    }



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.PlayerIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = recentSearchTableView.indexPathForCell(cell!) {
                    let seguedToDetail = segue.destinationViewController as? LOLSelfViewController
                    let player: Player = frc.objectAtIndexPath(indexPath) as! Player
                    let obj:NSDictionary = ["name":player.name!, "id":player.id!]
                    region = player.region!

                    seguedToDetail?.summoner = Summoner(data: obj)
                    seguedToDetail?.summonerName = player.name!
                    self.recentSearchTableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            default: break
            }
        }
    }
    

}
