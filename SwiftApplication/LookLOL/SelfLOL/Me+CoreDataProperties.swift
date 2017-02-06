//
//  Self+CoreDataProperties.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 5/4/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Me {

    @NSManaged var date: Date?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var region: String?
    @NSManaged var homePage: NSNumber?

}
