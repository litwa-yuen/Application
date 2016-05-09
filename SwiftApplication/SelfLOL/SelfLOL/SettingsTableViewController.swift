
import UIKit
import CoreData

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var summonerTextField: UITextField!
    @IBOutlet weak var regionPicker: UIPickerView!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var StatusCell: UITableViewCell!
    @IBOutlet weak var GameCell: UITableViewCell!
    @IBOutlet weak var messageCell: UITableViewCell!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var tap: UITapGestureRecognizer? = nil
    var showSummoner = Bool()
    let sectionMap = [2,3,1]
    var  mySummoner: Summoner?
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        summonerTextField.delegate = self
        regionPicker.delegate = self
        regionPicker.dataSource = self
        messageCell.hidden = true
        indicator.hidden = true
        regionPicker.selectRow(49995+(regionTuples[region]?.index)!, inComponent: 0, animated: true)
        setUpSummonerTextField()
        StatusCell.accessoryType = .Checkmark
        let result: [Me] = (try! context.executeFetchRequest(fetchMeRequest())) as! [Me]
        if !result.isEmpty {
            summonerTextField.text = result.first?.name
            let obj:NSDictionary = ["name":(result.first?.name)!, "id":(result.first?.id)!]
            mySummoner = Summoner(data: obj)
            mySummoner?.region = result.first?.region
            summonerTextField.rightView?.hidden = false
            showSummoner = true
            GameCell.accessoryType = .Checkmark
            StatusCell.accessoryType = .None
        }
    }
    
    func handleTap(sender: UIGestureRecognizer) {
        discardKeyboard()
    }
    
    func setUpSummonerTextField() {
        summonerTextField.returnKeyType = .Search
        summonerTextField.enablesReturnKeyAutomatically = true
        let rightView = UIView()
        
        rightView.frame = CGRectMake(0, 0, 20, 20)
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let button = UIButton(frame: CGRectMake(-1, 2, 14, 14))
        button.setBackgroundImage(UIImage(named: "verified"), forState: .Normal)
        button.userInteractionEnabled = false
        rightView.addSubview(button)
        summonerTextField.rightViewMode = UITextFieldViewMode.UnlessEditing
        summonerTextField.rightView = rightView
        summonerTextField.rightView?.hidden = true
        
    }
    
    // MARK: - Button Action
    @IBAction func verify(sender: UIButton) {
        indicator.hidden = false
        verifyButton.hidden = true
        indicator.startAnimating()
        getSummonerId(summonerTextField.text!)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionMap.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if !showSummoner && section == 1 {
            return 0
        }
        return sectionMap[section]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                StatusCell.accessoryType = .Checkmark
                GameCell.accessoryType = .None
                summonerTextField.text = ""
                showSummoner = false
                summonerTextField.rightView?.hidden = true
                messageCell.hidden = true
                deleteMeCoreData()
            case 1:
                showSummoner = true
                toggleAddButton(summonerTextField.text!)
                StatusCell.accessoryType = .None
                GameCell.accessoryType = .Checkmark
                
            default:
                break
            }
            tableView.reloadData()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Core Data
    func fetchMeRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Me")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func deleteMeCoreData() {
        let result: NSArray = (try! context.executeFetchRequest(fetchMeRequest())) as! [Player]
        for me in result {
            context.deleteObject(me as! NSManagedObject)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    
    // MARK: - UIPickerViewDataSource
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let mapResult : String = regionMap[row%11]
        return regionTuples[mapResult]?.title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        region = regionMap[row%11]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100000
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getSummonerId(textField.text!)
        return true
    }
    
    func toggleAddButton(text: String) {
        if text.isEmpty {
            verifyButton.enabled = false
        }
        else {
            verifyButton.enabled = true
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == summonerTextField {
            summonerTextField.rightView?.hidden = true
            let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            toggleAddButton(text)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        tap = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewController.handleTap(_:)))
        view.addGestureRecognizer(tap!)
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        summonerTextField.rightView?.hidden = true
        verifyButton.enabled = false
        return true
    }
    
    func discardKeyboard() {
        summonerTextField.endEditing(true)
        if tap != nil {
            view.removeGestureRecognizer(tap!)
        }
    }
    
    
    // MARK: - Riot API Calls
    func getSummonerId(summonerName: String) {
        messageCell.hidden = true
        discardKeyboard()
        if mySummoner?.name != summonerTextField.text || mySummoner?.region != region {
            if CheckReachability.isConnectedToNetwork() {
                let urlSummonerName: String = summonerName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                let trimmedSummonerName = summonerName.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                let url = NSURL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.4/summoner/by-name/\(urlSummonerName)?api_key=\(api_key)")
                let request = NSURLRequest(URL: url!)
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if(error == nil) {
                            do {
                                if let httpReponse = reponse as! NSHTTPURLResponse? {
                                    self.indicator.stopAnimating()
                                    self.indicator.hidden = true
                                    self.verifyButton.enabled = true
                                    self.verifyButton.hidden = false
                                    switch(httpReponse.statusCode) {
                                    case 200:
                                        self.deleteMeCoreData()
                                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                                        if let resultDict = object as? NSDictionary {
                                            if let dataSet = resultDict.objectForKey(trimmedSummonerName.lowercaseString) as? NSDictionary {
                                                let summoner = Summoner(data: dataSet)
                                                
                                                let context = self.context
                                                let ent = NSEntityDescription.entityForName("Me", inManagedObjectContext: context)
                                                let me = Me(entity: ent!, insertIntoManagedObjectContext: context)
                                                me.name = summoner.name
                                                self.summonerTextField.text = summoner.name
                                                me.id = summoner.id
                                                me.region = region
                                                me.date = NSDate()
                                                me.homePage = 1
                                                do {
                                                    try context.save()
                                                    self.summonerTextField.rightView?.hidden = false
                                                    
                                                } catch _ {
                                                }
                                            }
                                        }
                                    case 404:
                                        self.showReponseMessage("Not Found")
                                        
                                    case 503, 500:
                                        self.showReponseMessage("Service Unavailable")
                                    default:
                                        self.showReponseMessage("Wait for Update")
                                    }
                                }
                                
                            } catch {}
                        }
                    })
                }
                task.resume()
            }
            else {
                self.indicator.stopAnimating()
                self.indicator.hidden = true
                self.verifyButton.enabled = true
                self.verifyButton.hidden = false
                
                showReponseMessage("Network Unavailable")
            }
        }
        else {
            self.indicator.stopAnimating()
            self.indicator.hidden = true
            self.verifyButton.enabled = true
            self.verifyButton.hidden = false
        }
    }
    
    func showReponseMessage(message: String) {
        messageCell.hidden = false
        messageLabel.text = message
    }
    
}
