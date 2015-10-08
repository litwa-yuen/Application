//
//  StockMonitorViewController.swift
//  StockMon
//
//  Created by Lit Wa Yuen on 10/3/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import UIKit
import CoreData

class StockMonitorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - NSFetchedResultsControllerDelegate
    let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    func fetchData() {
        var stocksData = [Stocks]()
        let fetchRequest = NSFetchRequest(entityName: "Stocks")
        stocksData = (try! context.executeFetchRequest(fetchRequest)) as! [Stocks]
        for stock in stocksData {
            getStockDetail(stock.symbol)
        }
    }
    
    @IBOutlet weak var stockTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        stockTableView.dataSource = self
        refreshData()
    }
    
    func refreshData() {
        stockMgr.stocks.removeAll()
        fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - action
    @IBAction func addStock(sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Add Stock",
            message: "Please enter a Stock name ...",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Cancel)
            { (action) in
                // do nothing
        }
        alert.addAction(cancelAction)
        
        let addFriendAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (action) -> Void in
            if let tf = alert.textFields?.first as UITextField! {
                self.createStock(tf.text!)
            }
        }
        alert.addAction(addFriendAction)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "stock name"
        }
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func createStock(symbol:String){
        let context = self.context
        let ent = NSEntityDescription.entityForName("Stocks", inManagedObjectContext: context)
        let nStock = Stocks(entity: ent!, insertIntoManagedObjectContext: context)
        nStock.symbol = symbol
        do {
            try context.save()
        } catch _ {
        }
        refreshData()
    }
    
    func getStockDetail(stockSymbol: String) {
        let url = NSURL(string: "https://www.quandl.com/api/v3/datasets/WIKI/\(stockSymbol).json?rows=1")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let resultDict = object as? NSDictionary {
                            if let dataSet = resultDict.objectForKey("dataset") as? NSDictionary {
                                if let stockDatas = dataSet["data"] as? NSArray {
                                    stockMgr.putStockDetail(stockDatas[0] as! NSArray, symbol: stockSymbol)
                                    self.stockTableView.reloadData()
                                }
                            }
                        }
                    } catch {}
                }
            })
        }
        task.resume()
    }
    
    // MARK: - UITableViewDelegate
    
    private struct Storyboard {
        static let ReuseCellIdentifier = "stock"
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockMgr.stocks.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ReuseCellIdentifier, forIndexPath: indexPath)
        let stock = stockMgr.stocks[indexPath.row]
        cell.textLabel?.text = "\(stock.symbol)"
        cell.detailTextLabel?.text = "\(stock.close)"
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            
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
