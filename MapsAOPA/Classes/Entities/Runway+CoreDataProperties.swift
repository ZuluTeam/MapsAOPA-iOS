//
//  Runway+CoreDataProperties.swift
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

extension Runway {

    @NSManaged var length: NSNumber?
    @NSManaged var lightsType: NSNumber?
    @NSManaged var magneticCourse: String?
    @NSManaged var surfaceType: NSNumber?
    @NSManaged var thresholds: RunwayThresholds?
    @NSManaged var title: String?
    @NSManaged var trafficPatterns: String?
    @NSManaged var trueCourse: String?
    @NSManaged var width: NSNumber?
    @NSManaged var point: Point?

}
