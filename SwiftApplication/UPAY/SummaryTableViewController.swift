import UIKit

class SummaryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendMgr.evalute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendMgr.summary.count
    }
    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "sumaryCell"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier, for: indexPath) 
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let transaction = friendMgr.summary[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "\(transaction.oweName) owe \(transaction.paidName) \(formatter.string(from: NSNumber(value: transaction.amount))!)"
        return cell
    }
}
