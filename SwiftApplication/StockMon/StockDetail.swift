//
//  StockDetail.swift
//  StockMon
//
//  Created by Lit Wa Yuen on 10/4/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import Foundation

class StockDetail {
    var symbol: String
    var date = NSDate()
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var volume: Double
    
    init(data: NSArray, symbol: String) {
        self.symbol = symbol
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.date = dateFormatter.dateFromString(data[0] as! String)!
        self.open = data[1] as! Double
        self.high = data[2] as! Double
        self.low = data[3] as! Double
        self.close = data[4] as! Double
        self.volume = data[5] as! Double

    }
}
