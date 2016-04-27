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
    case G100LL = 0
    case G92
    case G95
    case Jet
    
    init?(type: String?)
    {
        switch type ?? ""
        {
        case "1": self = G100LL
        case "2": self = G92
        case "3": self = G95
        case "4": self = Jet
        default: return nil
        }
        
    }
}

class Fuel: NSManagedObject {

    convenience init?(dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext)
    {
        if let entity = NSEntityDescription.entityForName("Fuel", inManagedObjectContext: context)
        {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.type = FuelType(type: dictionary?["type_id"] as? String)?.rawValue
        }
        else
        {
            return nil
        }
    }

}
