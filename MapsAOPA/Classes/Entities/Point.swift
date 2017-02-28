//
//  Point.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc enum PointType : Int
{
    case unknown = -1
    case airport = 0
    case heliport
    
    init(type: String?) {
        switch type ?? "" {
        case "airport": self = .airport
        case "vert": self = .heliport
        default: self = .unknown
        }
        
    }
}

@objc enum PointBelongs : Int
{
    case unknown = -1
    case civil = 0
    case military
    case general
    case fss
    case dosaaf
    case experimantal
    
    init(string: String?) {
        switch string ?? "" {
        case "ГА": self = .civil
        case "МО": self = .military
        case "АОН": self = .general
        case "ФСБ": self = .fss
        case "ДОСААФ": self = .dosaaf
        case "ЭА": self = .experimantal
        default: self = .unknown
        }
    }
    
    func isMilitary() -> Bool {
        switch self
        {
        case .military, .fss, .experimantal: return true
        default: return false
        }
    }
}

class Point: NSManagedObject {
    
    public enum Keys : String {
        case index
        case belongs
        case type
        case runways
        case fuel
        case searchRegion
        case searchIndex
        case searchIndexRu
        case searchCity
        case searchTitle
        case searchTitleRu
    }
    
    
    func isServiced() -> Bool {
        return self.fuel?.count ?? 0 > 0
    }
    
    class func point(fromDictionary dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext) -> Point? {
        var dictionary = dictionary
        if let unwrappedDictionary = dictionary, let index = dictionary?[Point.Keys.index.rawValue] as? String {
            
            let point = findOrCreateObject(in: context, matching: NSPredicate(format: "%K == %@", Point.Keys.index.rawValue, index), forceConfigure: true, configure: {
                (point: Point) in
                _ = point.importDataFromDictionary(unwrappedDictionary)
                let pointDetails = point.details ?? PointDetails.createObject(in: context, configure: {
                    (details: PointDetails) in
                    _ = details.importDataFromDictionary(unwrappedDictionary)
                })
                point.details = pointDetails
                
                point.searchRegion = pointDetails?.region?.normalizedString
                point.searchIndex = point.index?.normalizedString
                point.searchIndexRu = point.indexRu?.normalizedString
                point.searchCity = pointDetails?.city?.normalizedString
                point.searchTitle = point.title?.normalizedString
                point.searchTitleRu = point.titleRu?.normalizedString
                
            })
            return point
        }
        else
        {
            return nil   
        }
    }
}

extension Point: Managed {
    
    public static var entityName : String {
        return "Point"
    }

    public static var defaultSortDescriptors : [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(index), ascending: true)]
    }
    
}

extension Point {
    
    enum FuelAvailability : String {
        case fuel
        case fuelOnRequest
    }
    
    override func transformImortedValue(_ value: Any, for key: String) -> NSObject? {
        switch key {
        case Point.Keys.belongs.rawValue :
            if let value = value as? String {
                return PointBelongs(string: value).rawValue as NSObject?
            }
        case Point.Keys.type.rawValue :
            if let value = value as? String {
                return PointType(type: value).rawValue as NSObject?
            }
        case Point.Keys.runways.rawValue :
            var dictionary = value as? [[String:AnyObject]]
            if let runwaysDict = value as? [String:AnyObject] {
                dictionary = [runwaysDict]
            }
            if let runwayDicts = dictionary, let context = self.managedObjectContext {
                let runways : NSMutableSet = NSMutableSet()
                for runwayDict in runwayDicts {
                    if let runwayDict = runwayDict["item"] as? [String:AnyObject] {
                        let runway = Runway.createObject(in: context, configure: { (runway) in
                            _ = runway.importDataFromDictionary(runwayDict)
                        })
                        if let runway = runway {
                            runways.add(runway)
                        }
                    }
                }
                return runways
            }
            return nil
        case Point.Keys.fuel.rawValue :
            var dictionary = value as? [[String: AnyObject]]
            if let fuelDict = value as? [String:AnyObject] {
                dictionary = [fuelDict]
            }
            if let fuelDicts = dictionary {
                var fuelArray : [Fuel] = []
                var fuelOnRequestArray : [Fuel] = []
                for fuelDict in fuelDicts {
                    if let fuelDict = fuelDict["item"] as? [String:AnyObject], let type = FuelType(type: fuelDict["type_id"] as? String ?? ""), let context = self.managedObjectContext {
                        
                        if let fuel = Fuel.findOrCreateObject(in: context, matching: NSPredicate(format: "type == %d", type.rawValue), forceConfigure: false, configure: {
                            (fuel: Fuel) in
                            _ = fuel.importDataFromDictionary(fuelDict)
                        }) {
                            if let existType = fuelDict["exists_id"] as? String, existType == "1" {
                                fuelArray.append(fuel)
                            } else {
                                fuelOnRequestArray.append(fuel)
                            }
                        }
                    }
                }
                return [FuelAvailability.fuel.rawValue : fuelArray, FuelAvailability.fuelOnRequest.rawValue : fuelOnRequestArray] as NSDictionary
            }
            return nil
        default:
            break
        }
        return super.transformImortedValue(value, for: key)
    }
    
    override func addRelatedObject(_ object: Any, for key: String) {
        switch key {
        case Point.Keys.runways.rawValue :
            if let runwaysSet = object as? NSSet, runwaysSet.count > 0 {
                self.runways = runwaysSet
            }
        case Point.Keys.fuel.rawValue :
            if let fuel = object as? [String : [Fuel]] {
                if let fuelArray = fuel[FuelAvailability.fuel.rawValue], fuelArray.count > 0 {
                    self.fuel = NSSet(array: fuelArray)
                }
                if let fuelOnRequestArray = fuel[FuelAvailability.fuelOnRequest.rawValue], fuelOnRequestArray.count > 0 {
                    self.fuelOnRequest = NSSet(array: fuelOnRequestArray)
                }
            }
        default:
            break
        }
    }
}
