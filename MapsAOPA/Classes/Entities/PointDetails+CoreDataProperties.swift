//
//  PointDetails+CoreDataProperties.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/21/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PointDetails {

    @NSManaged var elevation: NSNumber?
    @NSManaged var city: String?
    @NSManaged var comment: String?
    @NSManaged var contacts: NSObject?
    @NSManaged var countryId: NSNumber?
    @NSManaged var countryName: String?
    @NSManaged var declination: NSNumber?
    @NSManaged var email: String?
    @NSManaged var frequencies: NSObject?
    @NSManaged var imageAerial: String?
    @NSManaged var imagePlan: String?
    @NSManaged var infrastructure: String?
    @NSManaged var international: NSNumber?
    @NSManaged var lastUpdate: String?
    @NSManaged var pointClass: String?
    @NSManaged var region: String?
    @NSManaged var utcOffset: String?
    @NSManaged var verified: NSNumber?
    @NSManaged var website: String?
    @NSManaged var worktime: String?
    @NSManaged var point: Point?

}
