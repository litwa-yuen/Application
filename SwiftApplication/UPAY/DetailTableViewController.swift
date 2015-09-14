import UIKit

class DetailTableViewController: UITableViewController {
    
    
    var tranactions: [Transaction]? = nil
    var transDecs: String? = ""
    var friend: Friend? = nil {
        didSet {
            updateFromSearch()
        }
    }
    
    var friendData: Friends? = nil {
        didSet {
            update()
        }
    }
    
    func update() {
        self.title = friendData?.name
        transDecs = friendData?.desc
        for friend in friendMgr.friends {
            if friend.name == self.title {
                tranactions = friend.detail
            }
        }
        
    }
    
    func updateFromSearch() {
        self.title = friend?.name
        transDecs = friend?.desc
        tranactions = friend?.detail
    }

    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
 
    }


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        if let length = tranactions?.count {
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
        if let transaction = tranactions?[indexPath.row] {
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 22))
        headerView.backgroundColor = UIColor.blackColor()
        var descriptionLabel: UILabel = UILabel()
        descriptionLabel.frame = CGRectMake(5, 2, tableView.frame.size.width-5, 18)
        descriptionLabel.text = transDecs!
        descriptionLabel.textAlignment = NSTextAlignment.Left
        descriptionLabel.textColor = UIColor.whiteColor()
        
        headerView.addSubview(descriptionLabel)
        
        return headerView
    }
    

}
