
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
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: - Properties
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var tap: UITapGestureRecognizer? = nil
    var showSummoner = Bool()
    let sectionMap = [2,3,1]
    let maxSelect = 100000
    var  mySummoner: Summoner?
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            self.revealViewController().rearViewRevealWidth = SideOutWidth
            menuButton.action =  #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        let initSelect = maxSelect/regionTuples.count/2*regionTuples.count
        summonerTextField.delegate = self
        regionPicker.delegate = self
        regionPicker.dataSource = self
        messageCell.isHidden = true
        indicator.isHidden = true
        regionPicker.selectRow(initSelect+(regionTuples[region]?.index)!, inComponent: 0, animated: true)
        setUpSummonerTextField()
        StatusCell.accessoryType = .checkmark
        let result: [Me] = (try! context.fetch(fetchMeRequest())) as! [Me]
        if !result.isEmpty {
            summonerTextField.text = result.first?.name
            let obj:NSDictionary = ["name":(result.first?.name)!, "id":(result.first?.id)!]
            mySummoner = Summoner(data: obj)
            mySummoner?.region = result.first?.region
            summonerTextField.rightView?.isHidden = false
            showSummoner = true
            GameCell.accessoryType = .checkmark
            StatusCell.accessoryType = .none
        }
    }
    
    func handleTap(_ sender: UIGestureRecognizer) {
        discardKeyboard()
    }
    
    func setUpSummonerTextField() {
        summonerTextField.returnKeyType = .search
        summonerTextField.enablesReturnKeyAutomatically = true
        let rightView = UIView()
        
        rightView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let button = UIButton(frame: CGRect(x: -1, y: 2, width: 14, height: 14))
        button.setBackgroundImage(UIImage(named: "verified"), for: UIControlState())
        button.isUserInteractionEnabled = false
        rightView.addSubview(button)
        summonerTextField.rightViewMode = UITextFieldViewMode.unlessEditing
        summonerTextField.rightView = rightView
        summonerTextField.rightView?.isHidden = true
        
    }
    
    // MARK: - Button Action
    @IBAction func verify(_ sender: UIButton) {
        indicator.isHidden = false
        verifyButton.isHidden = true
        indicator.startAnimating()
        getSummonerId(summonerTextField.text!)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionMap.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if !showSummoner && section == 1 {
            return 0
        }
        return sectionMap[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                StatusCell.accessoryType = .checkmark
                GameCell.accessoryType = .none
                summonerTextField.text = ""
                showSummoner = false
                summonerTextField.rightView?.isHidden = true
                messageCell.isHidden = true
                deleteMeCoreData()
            case 1:
                showSummoner = true
                toggleAddButton(summonerTextField.text!)
                StatusCell.accessoryType = .none
                GameCell.accessoryType = .checkmark
                
            default:
                break
            }
            tableView.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Core Data
    func fetchMeRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Me")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func deleteMeCoreData() {
        let result: NSArray = (try! context.fetch(fetchMeRequest())) as! [Me] as NSArray
        for me in result {
            context.delete(me as! NSManagedObject)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    
    // MARK: - UIPickerViewDataSource
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let mapResult : String = regionMap[row%11]
        return regionTuples[mapResult]?.title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        region = regionMap[row%11]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return maxSelect
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getSummonerId(textField.text!)
        return true
    }
    
    func toggleAddButton(_ text: String) {
        if text.isEmpty {
            verifyButton.isEnabled = false
        }
        else {
            verifyButton.isEnabled = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == summonerTextField {
            summonerTextField.rightView?.isHidden = true
            let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            toggleAddButton(text)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        tap = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewController.handleTap(_:)))
        view.addGestureRecognizer(tap!)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        summonerTextField.rightView?.isHidden = true
        verifyButton.isEnabled = false
        return true
    }
    
    func discardKeyboard() {
        summonerTextField.endEditing(true)
        if tap != nil {
            view.removeGestureRecognizer(tap!)
        }
    }
    
    
    // MARK: - Riot API Calls
    func getSummonerId(_ summonerName: String) {
        messageCell.isHidden = true
        discardKeyboard()
        if mySummoner?.name != summonerTextField.text || mySummoner?.region != region {
            if CheckReachability.isConnectedToNetwork() {
                let urlSummonerName: String = summonerName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                let trimmedSummonerName = summonerName.replacingOccurrences(of: " ", with: "")
                
                let url = URL(string: "https://\(region).api.pvp.net/api/lol/\(region)/v1.4/summoner/by-name/\(urlSummonerName)?api_key=\(api_key)")
                let request = URLRequest(url: url!)
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, reponse, error) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        if(error == nil) {
                            do {
                                if let httpReponse = reponse as! HTTPURLResponse? {
                                    self.indicator.stopAnimating()
                                    self.indicator.isHidden = true
                                    self.verifyButton.isEnabled = true
                                    self.verifyButton.isHidden = false
                                    switch(httpReponse.statusCode) {
                                    case 200:
                                        self.deleteMeCoreData()
                                        let object = try JSONSerialization.jsonObject(with: data!, options: [])
                                        if let resultDict = object as? NSDictionary {
                                            if let dataSet = resultDict.object(forKey: trimmedSummonerName.lowercased()) as? NSDictionary {
                                                let summoner = Summoner(data: dataSet)
                                                
                                                let context = self.context
                                                let ent = NSEntityDescription.entity(forEntityName: "Me", in: context)
                                                let me = Me(entity: ent!, insertInto: context)
                                                me.name = summoner.name
                                                self.summonerTextField.text = summoner.name
                                                me.id = summoner.id as NSNumber?
                                                me.region = region
                                                me.date = Date()
                                                me.homePage = 1
                                                do {
                                                    try context.save()
                                                    self.summonerTextField.rightView?.isHidden = false
                                                    
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
                }) 
                task.resume()
            }
            else {
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                self.verifyButton.isEnabled = true
                self.verifyButton.isHidden = false
                
                showReponseMessage("Network Unavailable")
            }
        }
        else {
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.verifyButton.isEnabled = true
            self.verifyButton.isHidden = false
        }
    }
    
    func showReponseMessage(_ message: String) {
        messageCell.isHidden = false
        messageLabel.text = message
    }
    
}
