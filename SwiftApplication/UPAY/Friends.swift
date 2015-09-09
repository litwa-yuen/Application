//
//  Friends.swift
//  UPAY
//
//  Created by Lit Wa Yuen on 9/8/15.
//  Copyright (c) 2015 CS320. All rights reserved.
//

import Foundation
import CoreData
@objc(Friends)


class Friends: NSManagedObject {

    @NSManaged var amount: Double
    @NSManaged var name: String
    @NSManaged var multiplier: NSNumber

}
