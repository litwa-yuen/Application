//
//  Participants+CoreDataProperties.swift
//  UPAY1.1
//
//  Created by Lit Wa Yuen on 9/17/15.
//  Copyright © 2015 CS320. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Friends {

    @NSManaged var amount: Double
    @NSManaged var desc: String
    @NSManaged var multiplier: NSNumber?
    @NSManaged var name: String
    @NSManaged var identifier: String
    

}
