
import UIKit


class SearchViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var filteredFriend: [Friend]!
    
    var searchController: UISearchController!
    
    override func viewWillAppear(_ animated: Bool) {
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
        
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "searchFriend"
        static let DetailIdentifier = "detail"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as UITableViewCell?
        let friend = filteredFriend[(indexPath as NSIndexPath).row]
        if friend.multiplier == 1 {
            cell!.textLabel?.text = "\(friend.name)"
        }
        else {
            let broughtWith = friend.multiplier - 1
            cell!.textLabel?.text = "\(friend.name) + \(broughtWith)"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        cell!.detailTextLabel?.text = formatter.string(from: NSNumber(value: friend.amount))!
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriend.count
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        filteredFriend = searchText!.isEmpty ? friendMgr.friends : friendMgr.friends.filter({(friend: Friend) -> Bool in
            return friend.name.range(of: searchText!, options: .caseInsensitive) != nil
        })
        
        tableView.reloadData()
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.DetailIdentifier:
                let cell = sender as? UITableViewCell
                if let indexPath = tableView.indexPath(for: cell!) {
                    friendMgr.evalute()
                    let seguedToDetail = segue.destination as? DetailTableViewController
                    seguedToDetail?.friend = filteredFriend[(indexPath as NSIndexPath).row]
                }
            default: break
            }
        }
    }
}
