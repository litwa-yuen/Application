//
//  ParticipantsViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 9/17/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import UIKit
import CoreData
import ContactsUI
import GoogleMobileAds

class ParticipantsViewController: UIViewController, NSFetchedResultsControllerDelegate,
UITableViewDataSource, UITableViewDelegate, CNContactPickerDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var participantsTableView: UITableView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var googleBannerView: GADBannerView!
    
    let minNumberOfSessions = 5
    let APP_NAME = "UPAY"
    let APP_ID = "1071727468"

    let store = CNContactStore()
    let context: NSManagedObjectContext = (UIApplication.shared
        .delegate as! AppDelegate).managedObjectContext
    var frc: NSFetchedResultsController = NSFetchedResultsController<Friends>()
    
    func getFetchedResultsController() -> NSFetchedResultsController<Friends> {
        frc = NSFetchedResultsController(fetchRequest: friendFetchRequest(),
            managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }
    
    func friendFetchRequest() -> NSFetchRequest<Friends> {
        let fetchRequest = NSFetchRequest<Friends>(entityName: "Friends")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return  fetchRequest
    }
    
    func fetchData() {
        var friendData = [Friends]()
        let fetchRequest = NSFetchRequest<Friends>(entityName: "Friends")
        friendData = (try! context.fetch(fetchRequest)) 
        for friend in friendData {
            let number = Int(friend.multiplier!)
            friendMgr.addFriend(friend.name, amount: friend.amount, multiplier: number, desc: friend.desc, identifier: friend.identifier )
        }
    }
    
    func deleteCoreData() {
        var friendData = [Friends]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friends")
        friendData = (try! context.fetch(fetchRequest)) as! [Friends]
        for friend in friendData {
            context.delete(friend)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
        refresh()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tryToRateApp()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Warning!",
            message: "Are you sure you want to delete all transactions",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.cancel)
            { (action) in
                // do nothing
        }
        alert.addAction(cancelAction)
        
        let clearAllAction = UIAlertAction(title: "Clear", style: UIAlertActionStyle.default) { (action) -> Void in
            self.deleteCoreData()
            self.refresh()
        }
        alert.addAction(clearAllAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pickParticipant(_ sender: UIBarButtonItem) {
        
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            promptAddContactAlert(true)
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else{
                    self.promptAddContactAlert(false)
                    return
                }
                self.promptAddContactAlert(true)
            }
        default:
            promptAddContactAlert(false)
        }
    }
    
    func promptAddContactAlert(_ auth: Bool) {
        let alert = UIAlertController(title: nil, message: (auth) ? nil : "To enable Add from Contacts, tap Settings and turn on Contacts.", preferredStyle: .actionSheet)
        if auth == true {
            alert.addAction(UIAlertAction(
            title: "Add from Contacts", style: .default) { (action) -> Void in
                self.addFriendFromContacts()
                })
        }
        else {
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { (action) in
                // THIS IS WHERE THE MAGIC HAPPENS!!!!
                if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(appSettings)
                }})
        }
        alert.addAction(UIAlertAction(
        title: "Add from Name", style: .default) { (action) -> Void in
            self.addTempFriend()
            })
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel)
        { (action) in
            // do nothing
            })
        alert.modalPresentationStyle = .popover
        let ppc = alert.popoverPresentationController
        ppc?.barButtonItem = barButton
        present(alert, animated: true, completion: nil)

    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let newPar = (CNContactFormatter.string(from: contact, style: .fullName)!, contact.identifier)
    
        let tvc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionTableViewController") as? TransactionTableViewController
        tvc?.newParticipant = newPar
        self.navigationController?.pushViewController(tvc!, animated: true)
    }
    
    func addFriendFromContacts() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.displayedPropertyKeys = [CNContactEmailAddressesKey]
    
        contactPicker.predicateForEnablingContact = NSPredicate(format: "NOT (identifier IN %@)", friendMgr.friends.map{$0.identifier})
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)

    }
    
    func addTempFriend() {
        let alert = UIAlertController(
            title: "Add Friend",
            message: "Please enter a friend name ...",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.cancel)
            { (action) in
                // do nothing
        }
        alert.addAction(cancelAction)
        
        let addFriendAction = UIAlertAction(title: "Next", style: UIAlertActionStyle.default) { (action) -> Void in
            if let tf = alert.textFields?.first as UITextField! {
                
                if tf.text?.isEmpty == true {
                    let noTextalert = UIAlertController(
                        title: "Name is required",
                        message: nil,
                        preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(
                        title: "OK",
                        style: UIAlertActionStyle.cancel)
                        { (action) in
                            // do nothing
                    }
                    noTextalert.addAction(okAction)
                    self.present(noTextalert, animated: true, completion: nil)
                }
                
                let newPar = (tf.text!, UUID().uuidString)
                let tvc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionTableViewController") as? TransactionTableViewController
                tvc?.newParticipant = newPar
                self.navigationController?.pushViewController(tvc!, animated: true)
            }
        }
        alert.addAction(addFriendAction)
        
        alert.addTextField { (textField) -> Void in
            textField.returnKeyType = .next
            textField.enablesReturnKeyAutomatically = true
            textField.placeholder = "friend name"
        }
        present(alert, animated: true, completion: nil)

    }
    
    func refresh() {
        if CheckReachability.isConnectedToNetwork() == true {
            googleBannerView.isHidden = false
            googleBannerView.adUnitID = "ca-app-pub-2177302372559739/4031410603"
            googleBannerView.adSize = kGADAdSizeSmartBannerPortrait
            googleBannerView.delegate = self
            googleBannerView.rootViewController = self
            let request = GADRequest()
            request.testDevices = ["115f1beaa2017b6e9d2e9ead967bbb5b"]
            googleBannerView.load(request)
        }
        else {
            googleBannerView.isHidden = true
        }
        
        friendMgr.friends.removeAll()
        friendMgr.summary.removeAll()
        fetchData()
        friendMgr.evalute()
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        averageLabel.text = "Average: \(formatter.string(from: NSNumber(value: friendMgr.average()))!)"
        totalLabel.text = "Total: \(formatter.string(from: NSNumber(value: friendMgr.total()))!)"
        
        participantsTableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "Participant"
        static let DetailIdentifier = "detail"
        static let AddIdentifier = "add"
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
        let friend = frc.object(at: indexPath) 
        if friend.multiplier == 1 {
            cell.textLabel?.text = "\(friend.name)"
        }
        else {
            let broughtWith = (friend.multiplier) as! Int - 1
            cell.textLabel?.text = "\(friend.name) + \(broughtWith)"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        cell.detailTextLabel?.text = formatter.string(from: NSNumber(value: friend.amount))!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let managedObject: NSManagedObject = frc.object(at: indexPath) as NSManagedObject
        context.delete(managedObject)
        do {
            try context.save()
        } catch _ {
        }
        refresh()
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        bannerView.isHidden = false
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    func adView(_ bannerView: GADBannerView!,
                didFailToReceiveAdWithError error: GADRequestError!) {
        bannerView.alpha = 1
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 0
        })
        bannerView.isHidden = true
    }
    
    func showRateAppAlert() {
        let alert = UIAlertController(title: "Rate \(APP_NAME)", message: "If you enjoy using \(APP_NAME), would you mind taking a moment to rate it? It wouldn't take more than a minute. Thanks for your support!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Rate It Now", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id\(self.APP_ID)")!)
            alert.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "Remind me later", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(0, forKey: "numLaunches")
            alert.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")       // Hide the Alert
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tryToRateApp() {
        let neverRate = UserDefaults.standard.bool(forKey: "neverRate")
        let numLaunches = UserDefaults.standard.integer(forKey: "numLaunches") + 1
        if (!neverRate && (numLaunches >= minNumberOfSessions))
        {
            showRateAppAlert()
        }
        UserDefaults.standard.set(numLaunches, forKey: "numLaunches")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.DetailIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = participantsTableView.indexPath(for: cell!) {
                    let seguedToDetail = segue.destination as? DetailTableViewController
                    let nFriend: Friends = frc.object(at: indexPath) 
                    seguedToDetail?.friendData = nFriend
                }
            default: break
            }
        }
    }
}
