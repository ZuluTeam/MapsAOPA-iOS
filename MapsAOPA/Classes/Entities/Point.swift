//
//  Point.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

enum PointType : Int
{
    case airport = 0
    case heliport
    
    init?(type: String?) {
        switch type ?? "" {
        case "airport": self = .airport
        case "vert": self = .heliport
        default: return nil
        }
        
    }
}

enum PointBelongs : Int
{
    case civil = 0
    case military
    case general
    case fss
    case dosaaf
    case experimantal
    
    init?(string: String?) {
        switch string ?? "" {
        case "ГА": self = .civil
        case "МО": self = .military
        case "АОН": self = .general
        case "ФСБ": self = .fss
        case "ДОСААФ": self = .dosaaf
        case "ЭА": self = .experimantal
        default: return nil
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
    func isServiced() -> Bool {
        return self.fuel?.count ?? 0 > 0
    }
    
    class func point(fromDictionary dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext) -> Point? {
        var dictionary = dictionary
        if let index = dictionary?["index"] as? String {
            let currentPointRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
            currentPointRequest.predicate = NSPredicate(format: "index == %@", index)
            let point : Point
            do {
                if let currentPoint = try context.fetch(currentPointRequest).first as? NSManagedObject {
                    context.delete(currentPoint)
                }
                if let entity = NSEntityDescription.entity(forEntityName: "Point", in: context) {
                    point = Point(entity: entity, insertInto: context)
                } else {
                    return nil
                }
            } catch {
                return nil
            }
            point.index = dictionary?["index"] as? String
            point.indexRu = dictionary?["index_ru"] as? String
            point.type = PointType(type: dictionary?["type"] as? String)?.rawValue as NSNumber?
            point.active = Int(dictionary?["active"] as? String ?? "0") as NSNumber?
            point.belongs = PointBelongs(string: dictionary?["belongs"] as? String)?.rawValue as NSNumber?
            point.latitude = Double(dictionary?["lat"] as? String ?? "0.0") as NSNumber?
            point.longitude = Double(dictionary?["lon"] as? String ?? "0.0") as NSNumber?
            point.title = dictionary?["name"] as? String
            point.titleRu = dictionary?["name_ru"] as? String
            point.details = PointDetails(dictionary: dictionary, inContext: context)
            if let runways = dictionary?["vpp"] as? [String:AnyObject] {
                dictionary?["vpp"] = [runways] as AnyObject
            }
            if let runwayDicts = dictionary?["vpp"] as? [[String:AnyObject]] {
                for runwayDict in runwayDicts {
                    if let runwayDict = runwayDict["item"] as? [String:AnyObject] {
                        let runway = Runway(dictionary: runwayDict, inContext: context)
                        runway?.point = point
                    }
                }
            }
            if let fuel = dictionary?["fuel"] as? [String:AnyObject] {
                dictionary?["fuel"] = [fuel] as AnyObject
            }
            if let fuelDicts = dictionary?["fuel"] as? [[String:AnyObject]] {
                for fuelDict in fuelDicts {
                    if let fuelDict = fuelDict["item"] as? [String:AnyObject], let type = FuelType(type: fuelDict["type_id"] as? String ?? "") {
                        do {
                            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Fuel")
                            request.predicate = NSPredicate(format: "type == %d", type.rawValue)
                            let fuels = try context.fetch(request)
                            let fuel = fuels.first as? Fuel ?? Fuel(dictionary: fuelDict, inContext: context)
                            if let existType = fuelDict["exists_id"] as? String, existType == "1" {
                                let points = fuel?.points?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
                                points.add(point)
                                fuel?.points = points
                            } else {
                                let points = fuel?.pointsOnRequest?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
                                points.add(point)
                                fuel?.pointsOnRequest = points
                            }
                        } catch {
                            fatalError("Failed to fetch fuel")
                        }
                    }
                }
            }
            return point
        }
        else
        {
            return nil   
        }
    }
}
