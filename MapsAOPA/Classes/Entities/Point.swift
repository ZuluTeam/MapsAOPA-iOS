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
import CoreLocation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

enum PointType : Int
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
    
    var localized : String {
        return "point_type_\(self.rawValue)".localized
    }
}

enum PointBelongs : Int
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
    
    var localized : String {
        return "belongs_\(self.rawValue)".localized
    }
}

extension Point {
    
    func isServiced() -> Bool {
        return fuel.count > 0
    }
}

class Point: Object, Mappable {
    dynamic var active = false
    dynamic var belongs = -1
    dynamic var index: String = ""
    dynamic var indexRu: String? = nil
    dynamic var lights = 0
    dynamic var title: String? = nil
    dynamic var titleRu: String? = nil
    dynamic var type = -1
    dynamic var details: PointDetails?
    dynamic var parent: Point?
    dynamic var location : PointLocation?
    dynamic var latitude : Double = 0.0
    dynamic var longitude : Double = 0.0
    var fuel = List<Fuel>()
    var fuelOnRequest = List<Fuel>()
    var runways = List<Runway>()
    var children = List<Point>()
    
    dynamic var searchRegion : String? = nil
    dynamic var searchIndex : String? = nil
    dynamic var searchIndexRu : String? = nil
    dynamic var searchCity : String? = nil
    dynamic var searchTitle : String? = nil
    dynamic var searchTitleRu : String? = nil
    
    enum Keys : String {
        case type
        case index
        case fuel
        case fuelOnRequest
        case active
        case latitude
        case longitude
        case searchRegion
        case searchIndex
        case searchIndexRu
        case searchCity
        case searchTitle
        case searchTitleRu
    }
    
    private struct JSONKeys {
        static let index = "index"
        static let indexRu = "index_ru"
        static let lights = "lights"
        static let title = "name"
        static let titleRu = "name_ru"
        static let belongs = "belongs"
        static let type = "type"
        static let fuel = "fuel"
        static let fuelOnRequest = "fuel"
        static let location = "location"
        static let latitude = "lat"
        static let longitude = "lon"
        static let runways = "vpp"
        static let active = "active"
        static let searchRegion = "region"
        static let searchIndex = "index"
        static let searchIndexRu = "index_ru"
        static let searchCity = "city"
        static let searchTitle = "name"
        static let searchTitleRu = "name_ru"
    }
    
    required convenience init?(map: Map) {
        if map.JSON[JSONKeys.index] == nil || map.JSON[JSONKeys.latitude] == nil || map.JSON[JSONKeys.longitude] == nil {
            return nil
        }
        self.init()
    }
    
    func mapping(map: Map) {
        active <- (map[JSONKeys.active, ignoreNil: true], TransformBoolValue())
        belongs <- (map[JSONKeys.belongs, ignoreNil: true], belongsTransform)
        index <- map[JSONKeys.index]
        indexRu <- map[JSONKeys.indexRu]
        lights <- (map[JSONKeys.lights, ignoreNil: true], TransformIntValue())
        title <- map[JSONKeys.title]
        titleRu <- map[JSONKeys.titleRu]
        type <- (map[JSONKeys.type, ignoreNil: true], typeTransform)
        fuel <- (map[JSONKeys.fuel, ignoreNil: true], fuelTransform)
        fuelOnRequest <- (map[JSONKeys.fuelOnRequest, ignoreNil: true], fuelOnRequestTransform)
        runways <- (map[JSONKeys.runways, ignoreNil: true], runwaysTransform)
        latitude <- (map[Keys.latitude.rawValue], TransformDoubleValue())
        longitude <- (map[Keys.longitude.rawValue], TransformDoubleValue())

        searchRegion <- (map[JSONKeys.searchRegion], normalizedForSearchTransform)
        searchIndex <- (map[JSONKeys.searchIndex], normalizedForSearchTransform)
        searchIndexRu <- (map[JSONKeys.searchIndexRu], normalizedForSearchTransform)
        searchCity <- (map[JSONKeys.searchCity], normalizedForSearchTransform)
        searchTitle <- (map[JSONKeys.searchTitle], normalizedForSearchTransform)
        searchTitleRu <- (map[JSONKeys.searchTitleRu], normalizedForSearchTransform)
        
        details = Mapper<PointDetails>().map(JSON: map.JSON)
        location = Mapper<PointLocation>().map(JSON: map.JSON)
        
    }
    
    override static func primaryKey() -> String? {
        return "index"
    }
    
    var pointType : PointType {
        return PointType(rawValue: type) ?? .unknown
    }
    
    var pointBelongs : PointBelongs {
        return PointBelongs(rawValue: belongs) ?? .unknown
    }
}

class PointLocation : Object, Mappable {
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    
    
    private enum Keys : String {
        case latitude = "lat"
        case longitude = "lon"
    }
    
    var location : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        latitude <- (map[Keys.latitude.rawValue], TransformDoubleValue())
        longitude <- (map[Keys.longitude.rawValue], TransformDoubleValue())
    }
}


extension Point {
    
    fileprivate var belongsTransform : TransformJSONOf<Int, String> {
        return TransformJSONOf(fromJSON: { (value: String?) -> Int? in
            return PointBelongs(string: value).rawValue
        })
    }
    
    fileprivate var typeTransform : TransformJSONOf<Int, String> {
        return TransformJSONOf(fromJSON: { (value: String?) -> Int? in
            return PointType(type: value).rawValue
        })
    }
    
    fileprivate var runwaysTransform : TransformPointArrayContent<List<Runway>> {
        return TransformPointArrayContent(fromJSON: { (value) -> List<Runway>? in
            let list = List<Runway>()
            if let runwayDicts = value {
                
                for runwayDict in runwayDicts {
                    if let runwayDict = runwayDict["item"] as? [String:Any] {
                        
                        if let runway = Mapper<Runway>().map(JSON: runwayDict) {
                            list.append(runway)
                        }
                    }
                }
            }
            return list
        })
    }
    
    fileprivate var fuelTransform : TransformPointArrayContent<List<Fuel>> {
        return TransformPointArrayContent(fromJSON: { (value) -> List<Fuel>? in
            return self.getFuelArray(array: value)
        })
    }
    
    fileprivate var fuelOnRequestTransform : TransformPointArrayContent<List<Fuel>> {
        return TransformPointArrayContent(fromJSON: { (value) -> List<Fuel>? in
            return self.getFuelArray(array: value, onRequest: true)
        })
    }
    
    private func getFuelArray(array: [[String: AnyObject]]?, onRequest: Bool = false) -> List<Fuel>? {
        if let fuelDicts = array {
            var fuelArray : [[String:AnyObject]] = []
            for fuelDict in fuelDicts {
                if let fuel = fuelDict["item"] as? [String:AnyObject], let _ = FuelType(type: fuel["type_id"] as? String ?? "") {
                    if let existType = fuel["exists_id"] as? String, existType == "1" {
                        if onRequest == false {
                            fuelArray.append(fuel)
                        }
                    } else if onRequest == true {
                        fuelArray.append(fuel)
                    }
                }
            }
            if let objects = Mapper<Fuel>().mapArray(JSONObject: fuelArray) {
                let list = List<Fuel>()
                list.append(objectsIn: objects)
                return list
            }
        }
        return nil
    }
    
    fileprivate var normalizedForSearchTransform : TransformJSONOf<String, String> {
        return TransformJSONOf(fromJSON: { (value) -> String? in
            return value?.normalizedString
        })
    }
}

extension Point {
    
    public class func pointsWith(predicate: NSPredicate) -> [Point] {
        let realm = try! Realm()
        let sortDescriptors = [ SortDescriptor(keyPath: Point.Keys.index.rawValue, ascending: true) ]
        let points = realm.objects(Point.self).filter(predicate).sorted(by: sortDescriptors)
        return Array(points)
    }
    
    public class func searchPointsWith(predicate: NSPredicate) -> [Point] {
        let realm = try! Realm()
        let sortDescriptors = [
            SortDescriptor(keyPath: Point.Keys.index.rawValue, ascending: true),
            SortDescriptor(keyPath: Point.Keys.searchTitle.rawValue, ascending: true),
            SortDescriptor(keyPath: Point.Keys.searchTitleRu.rawValue, ascending: true)
        ]
        let points = realm.objects(Point.self).filter(predicate).sorted(by: sortDescriptors)
        return Array(points)
    }
    
}
