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
    
    func description() -> String
    {
        switch self
        {
        case .g100LL: return "100LL"
        case .g92: return "AI-92"
        case .g95: return "AI-95"
        case .jet: return "TC-1"
        }
    }
}

class Fuel: NSManagedObject {

    convenience init?(dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext)
    {
        if let entity = NSEntityDescription.entity(forEntityName: "Fuel", in: context)
        {
            self.init(entity: entity, insertInto: context)
            self.type = FuelType(type: dictionary?["type_id"] as? String)?.rawValue as NSNumber?
        }
        else
        {
            return nil
        }
    }

}
