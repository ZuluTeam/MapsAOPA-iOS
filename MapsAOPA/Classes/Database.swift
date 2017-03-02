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
            "\(Point.Keys.latitude.rawValue) >= \(region.center.latitude - region.span.latitudeDelta) AND " +
            "\(Point.Keys.longitude.rawValue) >= \(region.center.longitude - region.span.longitudeDelta) AND " +
            "\(Point.Keys.latitude.rawValue) <= \(region.center.latitude + region.span.latitudeDelta) AND " +
            "\(Point.Keys.longitude.rawValue) <= \(region.center.longitude + region.span.longitudeDelta)"
        
        let airportsFormat : String
        var connection : String = "OR"
        switch filter.airportsState {
        case .all: airportsFormat = "(\(Point.Keys.type.rawValue) = \(PointType.airport.rawValue))"
        case .active: airportsFormat = "(\(Point.Keys.type.rawValue) = \(PointType.airport.rawValue) AND \(Point.Keys.active.rawValue) = 1)"
        case .none: airportsFormat = "(\(Point.Keys.type.rawValue) != \(PointType.airport.rawValue))"; connection = "AND"
        }
        
        let heliportsFormat : String
        switch filter.heliportsState {
        case .all: heliportsFormat = "(\(Point.Keys.type.rawValue) = \(PointType.heliport.rawValue))"
        case .active: heliportsFormat = "(\(Point.Keys.type.rawValue) = \(PointType.heliport.rawValue) AND \(Point.Keys.active.rawValue) = 1)"
        case .none: heliportsFormat = "(\(Point.Keys.type.rawValue) != \(PointType.heliport.rawValue))"; connection = "AND"
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
    
    public func createDBContainer() {
        // register value transformers here
        
    }
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // TODO: add value transformers
        Point.registerValueTransformers()
        Runway.registerValueTransformers()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption : true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
//            let wrappedError = AOPAError.dataError.error()
//            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return managedObjectContext
    }()
    
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext (_ context: NSManagedObjectContext) {
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    context.rollback()
                }
            }
        }
    }
}
