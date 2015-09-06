
import UIKit
import CoreData

class SearchViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var filteredFriend: [Friend]!
    
    var searchController: UISearchController!
    
    override func viewWillAppear(animated: Bool) {
        filteredFriend = friendMgr.friends
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        filteredFriend = friendMgr.friends
        
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        // If we are using this same view controller to present the results
        // dimming it out wouldn't make sense.  Should set probably only set
        // this to yes if using another controller to display the search results.
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        tableView.reloadData()
    }
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "searchFriend"
        static let DetailIdentifier = "detail"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier) as! UITableViewCell
        let friend = filteredFriend[indexPath.row]
        cell.textLabel?.text = friend.name
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        cell.detailTextLabel?.text = formatter.stringFromNumber(friend.amount)!
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriend.count
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        filteredFriend = searchText.isEmpty ? friendMgr.friends : friendMgr.friends.filter({(friend: Friend) -> Bool in
            return friend.name.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.DetailIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell!) {
                    friendMgr.evalute()
                    let seguedToDetail = segue.destinationViewController as? DetailTableViewController
                    seguedToDetail?.friend = filteredFriend[indexPath.row]
                }
            default: break
            }
        }
    }
    
}