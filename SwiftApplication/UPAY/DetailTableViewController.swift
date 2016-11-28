import UIKit
import Firebase

class DetailTableViewController: UITableViewController {
    
    
    var tranactions: [Transaction]? = nil
    var transDecs: String? = ""
    var action: Action? = nil
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

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        if let length = tranactions?.count {
            return length
        }
        else {
            return 0
        }
    }

    
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "detailCell"
        static let edit = "edit"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier, for: indexPath) 
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let transaction = tranactions?[(indexPath as NSIndexPath).row] {
            cell.textLabel?.text = "\(transaction.oweName) owe \(transaction.paidName) \(formatter.string(from: NSNumber(value: transaction.amount))!)"
            if transaction.oweName == self.title {
                cell.textLabel?.textColor = UIColorFromRGB("D50000")
            }
            else {
                cell.textLabel?.textColor = UIColorFromRGB("00C853")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22))
        headerView.backgroundColor = UIColor.black
        let descriptionLabel: UILabel = UILabel()
        descriptionLabel.frame = CGRect(x: 5, y: 2, width: tableView.frame.size.width-5, height: 18)
        descriptionLabel.text = transDecs!
        descriptionLabel.textAlignment = NSTextAlignment.left
        descriptionLabel.textColor = UIColor.white
        
        headerView.addSubview(descriptionLabel)
        
        return headerView
    }
    
    func UIColorFromRGB(_ colorCode: String, alpha: Float = 1.0) -> UIColor {
        let scanner = Scanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.edit:
                let segueTo = segue.destination as! TransactionTableViewController
                segueTo.friend = friendData
                segueTo.action = action
            default: break
            }
        }
    }


    

}
