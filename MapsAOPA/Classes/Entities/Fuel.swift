//
//  Fuel.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData
import RealmSwift
import ObjectMapper

enum FuelType : Int
{
    case g100LL = 0
    case g92
    case g95
    case jet
    
    init?(type: String?)
    {
        switch type ?? ""
        {
        case "1": self = .g100LL
        case "2": self = .g92
        case "3": self = .g95
        case "4": self = .jet
        default: return nil
        }
    }
    
    var localized : String {
        return "fuel_type_\(self.rawValue)".localized
    }
}

class Fuel: Object, Mappable {
    
    
    dynamic var type: Int = -1
    let points = LinkingObjects(fromType: Point.self, property: Point.Keys.fuel.rawValue)
    let pointsOnRequest = LinkingObjects(fromType: Point.self, property: Point.Keys.fuelOnRequest.rawValue)

    fileprivate enum Keys : String {
        case type = "type_id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        type <- (map[Keys.type.rawValue], fuelTypeTransform)
    }
    
    override static func primaryKey() -> String? {
        return "type"
    }
    
}

extension Fuel {
    
    var fuelType : FuelType? {
        return FuelType(rawValue: type)
    }
    
    var localized : String? {
        return FuelType(rawValue: type)?.localized
    }
    
    fileprivate var fuelTypeTransform : TransformJSONOf<Int, String> {
        return TransformJSONOf(fromJSON: { (value: String?) -> Int? in
            return FuelType(type: value)?.rawValue
        })
    }
    
}
