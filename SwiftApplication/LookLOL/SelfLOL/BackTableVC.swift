//
//  BackTableVC.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 12/18/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import Foundation


class BackTableVC: UITableViewController {
    
    var TableArray = [String]()
    override func viewDidLoad() {
        TableArray = ["Home", "Trending", "Settings"]
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableArray[indexPath.row], for: indexPath) as UITableViewCell
        cell.imageView?.image = UIImage(named: TableArray[indexPath.row])
        cell.textLabel?.text = TableArray[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 16)
        
        
        return cell
    }
    
}
