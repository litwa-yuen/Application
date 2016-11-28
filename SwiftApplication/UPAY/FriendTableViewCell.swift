//
//  FriendTableViewCell.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/15/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unFriendButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var requestRemoveLabel: UILabel!
    
    var hitUser: User? {
        didSet{
            updateUI()
        }
    }
    

    
    var currentUser: FIRUser = FIRAuth.auth()!.currentUser!
    let database = FIRDatabase.database().reference()

    
    func updateUI() {
        nameLabel.text = hitUser?.name
        switch (hitUser?.type)! {
        case .FRIEND:
            unFriendButton.isHidden = false
            confirmButton.isHidden = true
            declineButton.isHidden = true
            requestRemoveLabel.isHidden = true
        case .RESPONSE:
            unFriendButton.isHidden = true
            confirmButton.isHidden = false
            declineButton.isHidden = false
            requestRemoveLabel.isHidden = true
        default:
            break
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func unfriendAction(_ sender: UIButton) {
        removeEntries()
        requestRemoveLabel.text = "unfriend"
        requestRemoveLabel.isHidden = false
        unFriendButton.isHidden = true
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        database.child("users").child(currentUser.uid).child("friends")
            .child((hitUser?.uid)!).updateChildValues(["type":FriendType.FRIEND.rawValue])
        database.child("users").child((hitUser?.uid)!).child("friends")
            .child(currentUser.uid).updateChildValues(["type":FriendType.FRIEND.rawValue])
        requestRemoveLabel.isHidden = false
        requestRemoveLabel.text = "friend"

        confirmButton.isHidden = true
        declineButton.isHidden = true

    }

    @IBAction func declineAction(_ sender: UIButton) {
        removeEntries()
        requestRemoveLabel.isHidden = false
        confirmButton.isHidden = true
        declineButton.isHidden = true

    }
    
    func removeEntries() {
        database.child("users").child(currentUser.uid).child("friends")
            .child((hitUser?.uid)!).removeValue()
        database.child("users").child((hitUser?.uid)!).child("friends")
            .child(currentUser.uid).removeValue()
    }
    
    
}
