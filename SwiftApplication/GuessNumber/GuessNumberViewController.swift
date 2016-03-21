import UIKit

class GuessNumberViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var minValueButton: UIButton!
    @IBOutlet weak var maxValueButton: UIButton!
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var guessNumberTextField: UITextField!
    @IBOutlet weak var editNumberTextField: UITextField!
    @IBOutlet weak var EditingLabel: UILabel!
    @IBOutlet weak var DefaultButton: UIButton!
    @IBOutlet weak var GuessButton: UIButton!
    
    var isEditingMin = false
    var isEditingNumber = false
    var buttonFlashing = false

    var minRange: Int? {
        didSet{
            minValueButton.setTitle("\(minRange!)", forState: .Normal)
        }
    }
    
    var maxRange: Int? {
        didSet{
            maxValueButton.setTitle("\(maxRange!)", forState: .Normal)
        }
    }
    
    var initMinValue: Int? {
        didSet{
            minValueButton.setTitle("\(initMinValue!)", forState: .Normal)
            minRange = initMinValue
        }
    }
    
    var initMaxValue: Int? {
        didSet{
            maxValueButton.setTitle("\(initMaxValue!)", forState: .Normal)
            maxRange = initMaxValue
        }
    }

    
    var result: Int? {
        willSet{
            if resultButton.currentTitle?.isEmpty == false {
                resultButton.setTitle("\(newValue!)", forState: .Normal)
            }
        }
    }

    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        editNumberTextField.delegate = self
        guessNumberTextField.delegate = self
        setup()
        
        // Do any additional setup after loading the view.
    }

    func setup() {
        isEditingNumber = false
        minValueButton.userInteractionEnabled = false
        maxValueButton.userInteractionEnabled = false
        EditingLabel.hidden = true
        DefaultButton.hidden = true
        GuessButton.hidden = false
        EditingLabel.hidden = true
        guessNumberTextField.hidden = false
        initMinValue = 1
        initMaxValue = 100
        result = Int(arc4random_uniform(99) + 2)
        resultButton.setBackgroundImage(UIImage(named: "resultBack"), forState: .Normal)
        resultButton.setTitle("", forState: .Normal)
        stopFlashingbutton()
        toggleAddButton(guessNumberTextField.text!)
        discardKeyboard()

    }
    
    @IBAction func touchResultButton(sender: UIButton) {
        if sender.currentTitle == "" {
            sender.setBackgroundImage(UIImage(named: "resultFront")
                , forState: .Normal)
            sender.setTitle("\(result!)", forState: .Normal)
        }
        else {
            sender.setBackgroundImage(UIImage(named: "resultBack"), forState: .Normal)
            sender.setTitle("", forState: .Normal)
        }
    }

    @IBAction func restart(sender: UIBarButtonItem) {
        resultButton.setBackgroundImage(UIImage(named: "resultBack"), forState: .Normal)
        resultButton.setTitle("", forState: .Normal)
        let randomNumber = Int(arc4random_uniform(UInt32(initMaxValue!-1) - UInt32(initMinValue!+1)) + UInt32(initMinValue!+1))
        result = randomNumber
        minRange = initMinValue
        maxRange = initMaxValue
    }

    @IBAction func EditMinMax(sender: UIBarButtonItem) {
        if sender.title == "Set Range" {
            sender.title = "Done"
            resultButton.setBackgroundImage(UIImage(named: "resultFront"), forState: .Normal)
            resultButton.setTitle("?", forState: .Normal)
            doneSetRange(false)
        }
        else {
            if maxRange! > minRange!+1 {
                sender.title = "Set Range"
                doneSetRange(true)
                initMaxValue = maxRange
                initMinValue = minRange
                result = Int(arc4random_uniform(UInt32(initMaxValue!-1) - UInt32(initMinValue!+1)) + UInt32(initMinValue!+1))
                stopFlashingbutton()
            }
            else {
                stopFlashingbutton()
                discardKeyboard()
                showMessageAlert("Invalid Range")
            }
            
        }
        
    }
    
    func doneSetRange(isDone: Bool) {
        isEditingNumber = !isDone
        EditingLabel.hidden = isDone
        GuessButton.hidden = !isDone
        minValueButton.userInteractionEnabled = !isDone
        maxValueButton.userInteractionEnabled = !isDone
        resultButton.userInteractionEnabled = isDone
        DefaultButton.hidden = isDone
        guessNumberTextField.hidden = !isDone
        guessNumberTextField.text = ""
        editNumberTextField.endEditing(true)
    }
    
    @IBAction func editMinValue(sender: UIButton) {
        editMinMaxValue(true)
        EditingLabel.text = "Editing minimum value"
        minValueButton.setTitle("", forState: .Normal)

    }
    
    @IBAction func editMaxValue(sender: UIButton) {
        editMinMaxValue(false)
        EditingLabel.text = "Editing maximum value"
        maxValueButton.setTitle("", forState: .Normal)
    }
    
    func editMinMaxValue(isMin: Bool) {
        checkEmptyTitleButton()
        stopFlashingbutton()
        isEditingMin = isMin
        startFlashingbutton()
        editNumberTextField.text = ""
        editNumberTextField.becomeFirstResponder()
    }
    
    @IBAction func reset(sender: UIButton) {
        setup()
    }
    
    @IBAction func guessNumber(sender: UIButton) {
        if let guessNumber = Int(guessNumberTextField.text!) {
            switch guessNumber {
            case result!:
                resultButton.setBackgroundImage(UIImage(named: "resultFront")
                    , forState: .Normal)
                resultButton.setTitle("\(result!)", forState: .Normal)
                self.guessNumberTextField.endEditing(true)
                showMessageAlert("HIT")
            case minRange!+1 ... result!:
                minRange = guessNumber
            case result! ... maxRange!-1:
                maxRange = guessNumber
            default: showMessageAlert("Not in Range")
                
            }
        }
        else {
            showMessageAlert("Invalid Number")
        }
        guessNumberTextField.text = ""
        toggleAddButton("")
    }
    
    func showMessageAlert(message: String) {
        let messageAlert = UIAlertController(
            title: "\(message)",
            message: nil,
            preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Cancel)
            { (action) in
                // do nothing
        }
        messageAlert.addAction(okAction)
        self.presentViewController(messageAlert, animated: true, completion: nil)

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if textField == guessNumberTextField {
            toggleAddButton(text)
        }
        else {
            if text.isEmpty == false {
                if isEditingMin == true {
                    minRange = Int(text)
                }
                else {
                    maxRange = Int(text)
                }
            }
            else {
                if isEditingMin == true {
                    minValueButton.setTitle("", forState: .Normal)
                }
                else {
                    maxValueButton.setTitle("", forState: .Normal)
                }
            }
        }
        return true
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        discardKeyboard()
        stopFlashingbutton()
    }
    
    func discardKeyboard() {
        self.guessNumberTextField.endEditing(true)
        self.editNumberTextField.endEditing(true)
        EditingLabel.text = "Editing ..."
        checkEmptyTitleButton()
    }
    
    func toggleAddButton(text: String) {
        if text.isEmpty {
            GuessButton.enabled = false
        }
        else {
            GuessButton.enabled = true
        }
    }

    func checkEmptyTitleButton() {
        if isEditingNumber == true {
            if isEditingMin == true  && minValueButton.currentTitle?.isEmpty == true {
                minRange = initMinValue
            }
            else if isEditingMin == false && maxValueButton.currentTitle?.isEmpty == true {
                maxRange = initMaxValue
            }
        }
    }
    
    func startFlashingbutton() {
        
        buttonFlashing = true
        minValueButton.alpha = 1
        
        UIView.animateWithDuration(1 , delay: 0.0, options: UIViewAnimationOptions.Repeat, animations: {
            
            if self.isEditingMin == true {
                self.minValueButton.alpha = 0
            }
            else {
                self.maxValueButton.alpha = 0
            }
            
            }, completion: {Bool in
        })
    }
    
    func stopFlashingbutton() {
        
        buttonFlashing = false
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: .BeginFromCurrentState, animations: {
            
            self.minValueButton.alpha = 1
            self.maxValueButton.alpha = 1
            
            }, completion: {Bool in
        })
    }
    
    

}
