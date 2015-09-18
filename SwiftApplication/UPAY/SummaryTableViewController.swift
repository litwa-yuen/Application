import UIKit

class SummaryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendMgr.summary.count
    }
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "sumaryCell"
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath) 
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        let transaction = friendMgr.summary[indexPath.row]
        cell.textLabel?.text = "\(transaction.oweName) owe \(transaction.paidName) \(formatter.stringFromNumber(transaction.amount)!)"
        
        return cell
    }
    
    
}
