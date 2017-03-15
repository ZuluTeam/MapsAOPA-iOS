//
//  Fuel.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

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

class Fuel: NSManagedObject {
    fileprivate enum Keys : String {
        case type
    }
}

extension Fuel : Managed {
    public static var entityName : String {
        return "Fuel"
    }
}

extension Fuel {
    
    override func transformImortedValue(_ value: Any, for key: String) -> NSObject? {
        switch key {
        case Fuel.Keys.type.rawValue :
            if let value = value as? String {
                return FuelType(type: value)?.rawValue as NSNumber?
            }
        default:
            break
        }
        return super.transformImortedValue(value, for: key)
    }
}
