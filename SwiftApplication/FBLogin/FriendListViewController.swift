//
//  FriendListViewController.swift
//  FBLogin
//
//  Created by Lit Wa Yuen on 9/20/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import UIKit
import FBSDKCoreKit


class FriendListViewController: UIViewController {
    
    @IBOutlet weak var friendListTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            getFriendList()
            getUserInfo()
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Facebook API
    func getFriendList() {
        
        let friendsRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/taggable_friends", parameters: ["fields":"id, name"])
        friendsRequest.startWithCompletionHandler({ (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let resultdict = result as? NSDictionary {
                    if let data = resultdict.objectForKey("data") as? NSArray {
                        for i in 0...data.count-1 {
                            if let valueDict = data[i] as? NSDictionary {
                                if let name = valueDict.objectForKey("name") as? String {
                                    self.friendListTextView.text =
                                        self.friendListTextView.text + "\n" + name
                                }
                            }
                            
                        }
                    }
                }
            }
            
        })
        
    }
    
    func getUserInfo () {
        let meRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name"])
        meRequest.startWithCompletionHandler ({ (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let resultdict = result as? NSDictionary {
                    if let username = resultdict.objectForKey("name") as? String {
                        let displayName = username + " (You)"
                        self.friendListTextView.text =
                            self.friendListTextView.text + "\n" + displayName
                    }
                }
            })
        })
    }

    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
