import UIKit

class DetailTableViewController: UITableViewController {
    
    
    var friend: Friend = Friend(name: "default", amount: 0.0) {
        didSet{
            update()
        }
    }
    
    func update() {
        self.title = friend.name
    }

    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
 
    }


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        if let length = friend.detail?.count {
            return length
        }
        else {
            return 0
        }
    }

    
    private struct Storyboard {
        static let ReuseCellIdentifier = "detailCell"
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        if let transaction = friend.detail?[indexPath.row] {
            cell.textLabel?.text = "\(transaction.oweName) owe \(transaction.paidName) \(formatter.stringFromNumber(transaction.amount)!)"
            if transaction.oweName == self.title {
                cell.textLabel?.textColor = UIColor.redColor()
            }
            else {
                cell.textLabel?.textColor = UIColor.greenColor()
            }
        }
        
        return cell
    }
    

}
