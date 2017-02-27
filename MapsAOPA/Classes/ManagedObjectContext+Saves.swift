//
//  ManagedObjectContext+Saves.swift
//  MapsAOPA
//
//  Created by Kate on 27/02/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData


extension NSManagedObjectContext {
    fileprivate var changedObjectsCount: Int {
        return insertedObjects.count + updatedObjects.count + deletedObjects.count
    }
    
    public func delayedSaveOrRollback(completion: @escaping (Bool) -> () = { _ in }) {
        let changeCountLimit = 100
        guard changeCountLimit >= changedObjectsCount else {
            return completion(false)
        }
        guard self.hasChanges else {
            return completion(true)
        }
        completion(self.saveOrRollback())
    }
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
}
