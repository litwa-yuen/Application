//
//  Friends.swift
//  UPAY
//
//  Created by Lit Wa Yuen on 9/4/15.
//  Copyright (c) 2015 CS320. All rights reserved.
//

import Foundation
import CoreData
@objc(Friends)


class Friends: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var amount: Double


}
