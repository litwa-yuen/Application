//
//  LineGraphViewController.swift
//  StockMon
//
//  Created by Lit Wa Yuen on 10/15/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import UIKit

class LineGraphViewController: UIViewController {

    var stockSymbol: String? = "" {
        didSet{
            self.title = stockSymbol
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
