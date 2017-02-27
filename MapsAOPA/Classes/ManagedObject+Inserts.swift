//
//  ManagedObject+Inserts.swift
//  MapsAOPA
//
//  Created by Kate on 22/02/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectImportProtocol {
    func shouldImport(from object: [String: AnyObject]) -> Bool
    func transformImortedValue(_ value: Any, for key: String) -> NSObject?
    func addRelatedObject(_ object: Any, for key: String)
}

enum ManagedObjectImportKeys : String {
    case keyName = "mappedKey"
    case keyNames = "mappedKeys"
    case useDefaultValue = "useDefaultValueWhenNotPresent"
    case customDateFormatKey = "dateFormat"
    case unixTimeString = "UnixTime"
}

extension NSManagedObject : ManagedObjectImportProtocol {
    
    public func shouldImport(from object: [String : AnyObject]) -> Bool {
        return true
    }
    
    public func transformImortedValue(_ value: Any, for key: String) -> NSObject? {
        return value as? NSObject
    }
    
    func addRelatedObject(_ object: Any, for key: String) {
        
    }
    
    public func importDataFromDictionary(_ object: [String: AnyObject]) -> Bool {
        guard shouldImport(from: object) == true else {
            return false
        }
        let attributes = self.entity.attributesByName
        self.setAttributes(attributes, forKeysWith: object)
        
        let relationships = self.entity.relationshipsByName
        self.setRelationships(relationships, forKeysWith: object)
        
        return true
    }
    
    private func valueForKeyPaths(_ keyPaths: [String]?, from object: [String: AnyObject], for attributeName: String) -> AnyObject? {
        
        var transformedValue : Any? = nil
        if let keyPath = keyPaths?.first, let value = object.valueForKeyPath(keyPath), keyPaths?.count == 1 {
            transformedValue = self.transformImortedValue(value, for: attributeName)
        } else if let keyPaths = keyPaths, keyPaths.count > 1, let dictionary = object.valueForKeyPaths(keyPaths) {
            transformedValue = self.transformImortedValue(dictionary, for: attributeName)
        }
        
        return transformedValue as AnyObject?
    }
    
    public func setAttributes(_ attributes: [String : NSAttributeDescription], forKeysWith object: [String: AnyObject]) {
        for (attributeName, attributeDescription) in attributes {
            let keyPaths = object.keysForAttribute(attributeDescription)
            
            if let value = valueForKeyPaths(keyPaths, from: object, for: attributeName) {
                self.setValue(attributeDescription.checkValue(value), forKey: attributeName)
            } else if (attributeDescription.userInfo?[ManagedObjectImportKeys.useDefaultValue.rawValue] as? Bool) == true {
                let value = attributeDescription.defaultValue
                self.setValue(value, forKey: attributeName)
            }
        }
    }
    
    public func setRelationships(_ relationships: [String : NSRelationshipDescription], forKeysWith object: [String: AnyObject]) {
        
        for (relationshipName, description) in relationships {
            
            let keyPaths = object.keysForRelationship(description)
            
            let value = valueForKeyPaths(keyPaths, from: object, for: relationshipName)
            if let value = value {
                addRelatedObject(value, for: relationshipName)
            }
            
        }
        
    }
    
}

extension Dictionary where Key: ExpressibleByStringLiteral {
    
    public func keysForAttribute(_ attributeDesc: NSAttributeDescription) -> [String]? {
        let attributeName = attributeDesc.name
        return keys(for: attributeName, userInfo: attributeDesc.userInfo)
    }
    
    public func keysForRelationship(_ relationshipDesc: NSRelationshipDescription) -> [String]? {
        let relationshipName = relationshipDesc.name
        return keys(for: relationshipName, userInfo: relationshipDesc.userInfo)
    }
    
    private func keys(for attributeName: String, userInfo: [AnyHashable : Any]?) -> [String]? {
        guard let key = userInfo?[ManagedObjectImportKeys.keyName.rawValue] as? String else {
            guard let keys = userInfo?[ManagedObjectImportKeys.keyNames.rawValue] as? String else {
                return [attributeName]
            }
            return keys.replacingOccurrences(of: " ", with: ",").components(separatedBy: ",")
        }
        return [key]
    }
    
    public func valueForKeyPaths(_ keyPaths: [String]) -> [String: Any]? {
        var dictionary : [String: Any] = [:]
        for keyPath in keyPaths {
            dictionary[keyPath] = valueForKeyPath(keyPath)
        }
        return dictionary
    }
    
    public func valueForKeyPath(_ keyPath: String) -> Any? {
        let keys = keyPath.components(separatedBy: ".")
        return valueForKeys(keys)
    }
    
    fileprivate func valueForKeys(_ keyPath: Array<String>) -> Any? {
        var keys = keyPath
        guard let first = keys.first as? Key else { print("Unable use key \(keys.first), should be on type: \(Key.self)"); return nil }
        let value = self[first]
        keys.remove(at: 0)
        if !keys.isEmpty, let subDict = value as? [String : AnyObject] {
            return subDict.valueForKeys(keys)
        }
        return value
    }
    
}
