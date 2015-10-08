//
//  StockManger.swift
//  StockMon
//
//  Created by Lit Wa Yuen on 10/4/15.
//  Copyright © 2015 CS320. All rights reserved.
//

import Foundation

var stockMgr: StockManger = StockManger()

class StockManger: NSObject {
    var stocks = [StockDetail]()

    func putStockDetail(data: NSArray, symbol: String) {
        stocks.append(StockDetail(data: data, symbol: symbol))
    }
}
