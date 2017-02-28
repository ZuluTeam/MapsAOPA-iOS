//
//  Point+CoreDataProperties.swift
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

extension Point {

    @NSManaged var active: NSNumber?
    @NSManaged var belongs: NSNumber?
    @NSManaged var index: String?
    @NSManaged var indexRu: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var lights: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var title: String?
    @NSManaged var titleRu: String?
    @NSManaged var type: NSNumber?
    @NSManaged var children: NSSet?
    @NSManaged var details: PointDetails?
    @NSManaged var fuel: NSSet?
    @NSManaged var fuelOnRequest: NSSet?
    @NSManaged var parent: Point?
    @NSManaged var runways: NSSet?
    
    @NSManaged var searchRegion : String?
    @NSManaged var searchIndex : String?
    @NSManaged var searchIndexRu : String?
    @NSManaged var searchCity : String?
    @NSManaged var searchTitle : String?
    @NSManaged var searchTitleRu : String?

}
