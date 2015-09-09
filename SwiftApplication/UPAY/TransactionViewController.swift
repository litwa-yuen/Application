import UIKit
import CoreData

class TransactionViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableFriends: UITableView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            toggleAddButton()
        }
    }
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var shareTextField: UITextField!
    
    
    // MARK: - NSFetchedResultsControllerDelegate
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var nFriend: Friends? = nil
    
    var frc: NSFetchedResultsController = NSFetchedResultsController()
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        frc = NSFetchedResultsController(fetchRequest: friendFetchRequest(), managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
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
        friendData = context?.executeFetchRequest(fetchRequest, error: nil) as! [Friends]
        for friend in friendData {
            let number = Int(friend.multiplier)
            friendMgr.addFriend(friend.name, amount: friend.amount, multiplier: number)
        }
    }
    
    func deleteCoreData() {
        var friendData = [Friends]()
        var fetchRequest = NSFetchRequest(entityName: "Friends")
        friendData = context?.executeFetchRequest(fetchRequest, error: nil) as! [Friends]
        for friend in friendData {
            context?.deleteObject(friend)
        }
        context?.save(nil)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableFriends.reloadData()
    }
    
    // MARK: - Button action
    
    @IBAction func addToQueue(sender: UIButton) {
        newFriend()
        self.view.endEditing(true)
        amountTextField.text = nil
        searchTextField.text = nil
        refresh()
        tableFriends.reloadData()
    }
    
    @IBAction func clearAll(sender: UIButton) {
        deleteCoreData()
        refresh()
        tableFriends.reloadData()
    }
    
    func newFriend() {
        let context = self.context
        let ent = NSEntityDescription.entityForName("Friends", inManagedObjectContext: context!)
        let nFriend = Friends(entity: ent!, insertIntoManagedObjectContext: context)
        nFriend.name = searchTextField.text
        
        if amountTextField?.text == nil || amountTextField?.text == "" {
            nFriend.amount = 0.0
        }
        else {
            nFriend.amount = (amountTextField.text as NSString).doubleValue
        }
        
        if shareTextField.text.isEmpty || shareTextField.text.toInt()! < 1 {
            nFriend.multiplier = 1
        }
        else {
            nFriend.multiplier = shareTextField.text.toInt()!
        }
        context?.save(nil)
    }
    
    func toggleAddButton () {
        if searchTextField.text.isEmpty {
            addButton.enabled = false
        }
        else {
            addButton.enabled = true
        }
        
    }
    
    func refresh() {
        friendMgr.friends.removeAll()
        friendMgr.summary.removeAll()
        searchTextField.text = ""
        amountTextField.text = ""
        shareTextField.text = ""
        fetchData()
        friendMgr.evalute()
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        averageLabel.text = "Average is \(formatter.stringFromNumber(friendMgr.average())!)"
        totalLabel.text = "Total is \(formatter.stringFromNumber(friendMgr.total())!)"
        toggleAddButton()
    }
    
    
    // MARK: - MVC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        frc = getFetchedResultsController()
        frc.delegate = self
        frc.performFetch(nil)
        refresh()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == searchTextField {
            let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            if !text.isEmpty {
                addButton.enabled = true
            }
            else {
                addButton.enabled = false
            }
        }
        
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRow = frc.sections?[section].numberOfObjects
        return numberOfRow!
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = frc.sections?.count
        return numberOfSections!
        
    }
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "transFriend"
        static let DetailIdentifier = "detail"
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
        context?.deleteObject(managedObject)
        context?.save(nil)
        refresh()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.DetailIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = tableFriends.indexPathForCell(cell!) {
                    let seguedToDetail = segue.destinationViewController as? DetailTableViewController
                    let nFriend: Friends = frc.objectAtIndexPath(indexPath) as! Friends
                    seguedToDetail?.friendData = nFriend
                }
            default: break
            }
        }
    }
    
}
