//
//  ManagedObjectHelper.swift
//  MapsAOPA
//
//  Created by Kate on 22/02/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//  Inspired by 2015 objc.io.

import Foundation
import CoreData

public protocol Managed : class, NSFetchRequestResult {
    
    static var entityName : String { get }
    static var defaultSortDescriptors : [NSSortDescriptor] { get }
    static var defaultPredicate : NSPredicate { get }
    var managedObjectContext : NSManagedObjectContext? { get }
}

public protocol DefaultManaged: Managed {}

extension DefaultManaged {
    public static var defaultPredicate : NSPredicate { return NSPredicate(value: true) }
}

extension Managed {
    public static var defaultSortDescriptors : [NSSortDescriptor] { return [] }
    public static var defaultPredicate : NSPredicate { return NSPredicate(value: true) }
}

extension Managed where Self: NSManagedObject {

    
    fileprivate static var sortedFetchRequest: NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = NSPredicate(value: true)
        return request
    }
    
    public static func createObject(in context: NSManagedObjectContext, configure: ((Self) -> ())? = nil) -> Self? {
        let createdObject : Self = context.insertObject()
        if let configure = configure {
            configure(createdObject)
        }
        return createdObject
    }
    
    public static func findOrCreateObject(in context: NSManagedObjectContext, matching predicate: NSPredicate, forceConfigure : Bool = false, configure: ((Self) -> ())? = nil) -> Self? {
        guard let object = findOrFetchObject(in: context, matching: predicate) else {
            return createObject(in: context, configure: configure)
        }
        if let configure = configure, forceConfigure == true {
            configure(object)
        }
        return object
    }
    
    public static func findOrFetchObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetchObject(in: context, configurationBlock: { (request) in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }).first
        }
        return object
    }
    
    fileprivate static func fetchObject(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> () = { _ in }) -> [Self] {
        let request = sortedFetchRequest
        configurationBlock(request)
        guard let result = try! context.fetch(request) as? [Self] else {
            fatalError("Wrong objects type")
        }
        return result
    }
    
    public static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }
    
}

extension NSManagedObjectContext {
    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            fatalError("Wrong object type")
        }
        return object
    }
}
