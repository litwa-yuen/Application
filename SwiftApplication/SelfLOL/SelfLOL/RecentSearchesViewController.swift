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
        
    let context: NSManagedObjectContext = (UIApplication.shared
        .delegate as! AppDelegate).managedObjectContext
    var frc: NSFetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>()
    
    func recentSearchFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return  fetchRequest
    }

    func getFetchedResultsController() -> NSFetchedResultsController<Player> {
        frc = NSFetchedResultsController(fetchRequest: recentSearchFetchRequest() ,
                                         managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc as! NSFetchedResultsController<Player>
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        frc = getFetchedResultsController() as! NSFetchedResultsController<NSFetchRequestResult>
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
    @IBAction func clear(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
  
        alert.addAction(UIAlertAction(
        title: "Clear Recent Searches", style: .default) { (action) -> Void in
            self.deleteCoreData()
            })
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel)
        { (action) in
            // do nothing
            })
        alert.modalPresentationStyle = .popover
        let ppc = alert.popoverPresentationController
        ppc?.barButtonItem = clearButton
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "recent"
        static let PlayerIdentifier = "player"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRow = frc.sections?[section].numberOfObjects
        return numberOfRow!
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = frc.sections?.count
        return numberOfSections!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier, for: indexPath)
        let player = frc.object(at: indexPath) as! Player
        cell.textLabel?.text = "\(player.name!)"
        cell.detailTextLabel?.text = "(\((player.region?.uppercased())!))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let managedObject: NSManagedObject = frc.object(at: indexPath) as! NSManagedObject
        context.delete(managedObject)
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        recentSearchTableView.reloadData()
    }
    
    func deleteCoreData() {
        var playersData = [Player]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
        playersData = (try! context.fetch(fetchRequest)) as! [Player]
        for player in playersData {
            context.delete(player)
        }
        do {
            try context.save()
        } catch _ {
        }
    }



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.PlayerIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = recentSearchTableView.indexPath(for: cell!) {
                    let seguedToDetail = segue.destination as? LOLSelfViewController
                    let player: Player = frc.object(at: indexPath) as! Player
                    let obj:NSDictionary = ["name":player.name!, "id":player.id!]
                    player.date = Date()
                    do {
                        try context.save()
                    } catch _ {
                    }
                    region = player.region!
                    seguedToDetail?.summoner = Summoner(data: obj)
                    seguedToDetail?.summonerName = player.name!
                    self.recentSearchTableView.deselectRow(at: indexPath, animated: true)
                }
            default: break
            }
        }
    }
    

}
