//
//  CheckReachability.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 1/12/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//

import Foundation


open class CheckReachability {
    class func isConnectedToNetwork() -> Bool {
        let reachability: Reachability = Reachability.forInternetConnection()
        let networkStatus: Int = reachability.currentReachabilityStatus().rawValue
        return networkStatus != 0
    }
}
