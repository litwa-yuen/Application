//
//  RunesViewController.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 11/26/15.
//  Copyright © 2015 lit.wa.yuen. All rights reserved.
//

import UIKit

class RunesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var runeTableView: UITableView!
    
    var runes: [Rune]? = [Rune]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    fileprivate struct Storyboard {
        static let ReuseCellIdentifier = "rune"
        static let BorderColor = "607D8B"
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (runes?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ReuseCellIdentifier) as! RuneTableViewCell
        cell.layer.borderColor = UIColorFromRGB(Storyboard.BorderColor).cgColor
        cell.layer.borderWidth = 1.0
        cell.rune = runes![(indexPath as NSIndexPath).row]
        return cell
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
