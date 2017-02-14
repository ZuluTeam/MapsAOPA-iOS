//
//  Database.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import CoreData
import ReactiveSwift
import MapKit

class Database
{
    static let sharedDatabase = Database()
    
    fileprivate init() { }
    
    static func pointsPredicate(forRegion region: MKCoordinateRegion, withFilter filter: PointsFilter) -> NSPredicate
    {
        var format =
            "latitude >= \(region.center.latitude - region.span.latitudeDelta) AND " +
            "longitude >= \(region.center.longitude - region.span.longitudeDelta) AND " +
            "latitude <= \(region.center.latitude + region.span.latitudeDelta) AND " +
            "longitude <= \(region.center.longitude + region.span.longitudeDelta)"
        
        let airportsFormat : String
        var connection : String = "OR"
        switch filter.airportsState {
        case .all: airportsFormat = "(type = \(PointType.airport.rawValue))"
        case .active: airportsFormat = "(type = \(PointType.airport.rawValue) AND active = 1)"
        case .none: airportsFormat = "(type != \(PointType.airport.rawValue))"; connection = "AND"
        }
        
        let heliportsFormat : String
        switch filter.heliportsState {
        case .all: heliportsFormat = "(type = \(PointType.heliport.rawValue))"
        case .active: heliportsFormat = "(type = \(PointType.heliport.rawValue) AND active = 1)"
        case .none: heliportsFormat = "(type != \(PointType.heliport.rawValue))"; connection = "AND"
        }
        
        format += " AND (\(airportsFormat) \(connection) \(heliportsFormat))"

        return NSPredicate(format: format, argumentArray: nil)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "MapsAOPA", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = AOPAError.dataError.error()
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext (_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
