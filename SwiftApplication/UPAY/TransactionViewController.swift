import UIKit
import CoreData

class TransactionViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableFriends: UITableView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    
    @IBAction func addToQueue(sender: UIButton) {
        if amountTextField?.text == nil || amountTextField?.text == "" {
            
            friendMgr.addFriend(searchTextField.text, amount: 0.0)
        }
        else {
            friendMgr.addFriend(searchTextField.text, amount: (amountTextField.text as NSString).doubleValue )
        }
        self.view.endEditing(true)
        amountTextField.text = nil
        searchTextField.text = nil
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        averageLabel.text = "Average is \(formatter.stringFromNumber(friendMgr.average())!)"
        totalLabel.text = "Total is \(formatter.stringFromNumber(friendMgr.total())!)"
        friendMgr.evalute()
        tableFriends.reloadData()
    }
    
    @IBAction func clearAll(sender: UIButton) {
        friendMgr.friends.removeAll()
        friendMgr.summary.removeAll()
        tableFriends.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        tableFriends.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - UITextFieldDelegate
    
 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendMgr.friends.count
    }
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "transFriend"
        static let DetailIdentifier = "detail"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let friend = friendMgr.friends[indexPath.row]
        cell.textLabel?.text = friend.name
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        cell.detailTextLabel?.text = formatter.stringFromNumber(friend.amount)!
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            friendMgr.friends.removeAtIndex(indexPath.row)
            tableFriends.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case Storyboard.DetailIdentifier:
                    let cell = sender as? UITableViewCell
                    if let indexPath = tableFriends.indexPathForCell(cell!) {
                        friendMgr.evalute()
                        let seguedToDetail = segue.destinationViewController as? DetailTableViewController
                        seguedToDetail?.friend = friendMgr.friends[indexPath.row]
                }
            default: break
            }
        }
    }

}
