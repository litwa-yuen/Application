import UIKit
import CoreData

class TransactionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var shareTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var friendName: String = ""{
        didSet{
            nameLabel?.text = friendName
        }
    }
    // MARK: - NSFetchedResultsControllerDelegate
    let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var nFriend: Friends? = nil
    
    
    // MARK: - Button action
    
    @IBAction func save(sender: UIBarButtonItem) {
        newFriend()
        self.view.endEditing(true)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func newFriend() {
        let context = self.context
        let ent = NSEntityDescription.entityForName("Friends", inManagedObjectContext: context)
        let nFriend = Friends(entity: ent!, insertIntoManagedObjectContext: context)
        nFriend.name = nameLabel.text!
        
        if amountTextField?.text == nil || amountTextField?.text == "" {
            nFriend.amount = 0.0
        }
        else {
            nFriend.amount = (amountTextField.text as NSString).doubleValue
        }
        
        if shareTextField.text.isEmpty || shareTextField.text.toInt()! < 1 {
            nFriend.multiplier = 1
        }
        else {
            nFriend.multiplier = shareTextField.text.toInt()!
        }
        context.save(nil)
    }
    
    // MARK: - MVC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel?.text = friendName
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    

    
}
