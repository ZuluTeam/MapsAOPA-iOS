//
//  PointDetails.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

enum PointCountry : Int
{
    case Russia = 0
    case Ukraine
    case Kazakhstan
    case Belarus
    
    init?(code: String?)
    {
        switch code ?? ""
        {
        case "1": self = Russia
        case "2": self = Ukraine
        case "3": self = Kazakhstan
        case "4": self = Belarus
        default: return nil
        }
    }
}

class PointDetails: NSManagedObject {

    convenience init?(dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext)
    {
        if let entity = NSEntityDescription.entityForName("PointDetails", inManagedObjectContext: context)
        {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.city = dictionary?["city"] as? String
            self.comment = dictionary?["comments"] as? String
            self.countryId = PointCountry(code: dictionary?["country_id"] as? String)?.rawValue
            self.declination = Float(dictionary?["delta_m"] as? String ?? "")
            self.email = dictionary?["email"] as? String
            self.altitude = Int(dictionary?["height"] as? String ?? "")
            self.imageAerial = dictionary?["img_aerial"] as? String
            self.imagePlan = dictionary?["img_plan"] as? String
            self.infrastructure = dictionary?["infrastructure"] as? String
            self.international = Int(dictionary?["international"] as? String ?? "")
            self.pointClass = dictionary?["class"] as? String
            self.region = dictionary?["region"] as? String
            self.utcOffset = dictionary?["utc_offset"] as? String
            self.verified = Int(dictionary?["verified"] as? String ?? "")
            self.website = dictionary?["website"] as? String
            self.worktime = dictionary?["worktime"] as? String
            
            self.lastUpdate = dictionary?["last_update"] as? String
            
            if let contactDicts = dictionary?["contact"] as? [[String:AnyObject]]
            {
                let contacts = contactDicts.map({ item -> [String:AnyObject] in
                    var contact = item
                    contact["id"] = nil
                    return contact })
                var result : [[String:AnyObject]] = []
                for contact in contacts
                {
                    if let value = contact["value"] as? String
                    {
                        let values = value.componentsSeparatedByString(",").map({ $0.trim() }).filter({ $0.length > 0 })
                        for phone in values
                        {
                            var c : [String:AnyObject] = [:]
                            c["fio"] = contact["fio"]
                            c["value"] = phone
                            c["type"] = contact["type"]
                            c["type_id"] = contact["type_id"]
                            result.append(c)
                        }
                    }
                }
                self.contacts = result
            }
            if let freqDicts = dictionary?["freq"] as? [[String:AnyObject]]
            {
                let frequencies = freqDicts.map({ item -> [String:AnyObject] in
                    var frequency = item
                    frequency["id"] = nil
                    return frequency })
                self.frequencies = frequencies
            }
        }
        else
        {
            return nil
        }
    }
}
