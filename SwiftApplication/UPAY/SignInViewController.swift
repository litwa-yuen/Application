//
//  SignInViewController.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 10/2/16.
//  Copyright © 2016 CS320. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                self.performSegue(withIdentifier: "FriendsList", sender: nil)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let friends = FIRDatabase.database().reference()
            friends.child("users").child((user?.uid)!).updateChildValues(["email": (user?.email)!, "type":FriendType.SELF.rawValue,
                                                                 "name": (user?.displayName)!, "uid":(user?.uid)!, "createDate": NSDate().timeIntervalSince1970])

            self.performSegue(withIdentifier: "FriendsList", sender: nil)
        }
    }
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
