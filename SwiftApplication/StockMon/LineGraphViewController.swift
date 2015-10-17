//
//  LineGraphViewController.swift
//  StockMon
//
//  Created by Lit Wa Yuen on 10/15/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import UIKit

class LineGraphViewController: UIViewController, LineChartViewDataSource{

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var lineGraph: LineChartView! {
        didSet{
            lineGraph.dataSource = self
        }
    }
    
    var nDays = [Double]()
    var seletedStockDetail: StockDetail? = nil {
        didSet{
            symbolLabel?.text = seletedStockDetail?.symbol
            nDays.append((seletedStockDetail?.close)!)
            getStockDetail((seletedStockDetail?.symbol)!)
        }
    }
    var days = 7 {
        didSet{
            
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
    
    
    func getStockDetail(stockSymbol: String) {
        let url = NSURL(string: "https://www.quandl.com/api/v3/datasets/WIKI/\(stockSymbol).json?rows=\(days)")
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, reponse, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(error == nil) {
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let resultDict = object as? NSDictionary {
                            if let dataSet = resultDict.objectForKey("dataset") as? NSDictionary {
                                if let stockDatas = dataSet["data"] as? NSArray {
                                    for stockData in stockDatas {
                                        let detail: StockDetail = StockDetail(data: stockData as! NSArray, symbol: stockSymbol, lastClose: 0)
                                        print("Update UI\(detail.close)")
                                        self.nDays.append(detail.close)
                                        self.updateUI()
                                        
                                    }
                                  
                                }
                            }
                        }
                    } catch {}
                }
            })
        }
        task.resume()
    }
    
    private func updateUI() {
        lineGraph.setNeedsDisplay()
    }
    
    func graphPointsForLineChart(sender: LineChartView) -> [Double]? {
        return nDays
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
