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
    case russia = 0
    case ukraine
    case kazakhstan
    case belarus
    
    init?(code: String?) {
        switch code ?? ""
        {
        case "1": self = .russia
        case "2": self = .ukraine
        case "3": self = .kazakhstan
        case "4": self = .belarus
        default: return nil
        }
    }
}

class PointDetails: NSManagedObject {

    convenience init?(dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "PointDetails", in: context) {
            var dictionary = dictionary
            self.init(entity: entity, insertInto: context)
            self.city = dictionary?["city"] as? String
            self.comment = dictionary?["comments"] as? String
            self.countryId = PointCountry(code: dictionary?["country_id"] as? String)?.rawValue as NSNumber?
            self.declination = Float(dictionary?["delta_m"] as? String ?? "") as NSNumber?
            self.email = dictionary?["email"] as? String
            self.elevation = Int(dictionary?["height"] as? String ?? "") as NSNumber?
            self.imageAerial = dictionary?["img_aerial"] as? String
            self.imagePlan = dictionary?["img_plan"] as? String
            self.infrastructure = dictionary?["infrastructure"] as? String
            self.international = Int(dictionary?["international"] as? String ?? "") as NSNumber?
            self.pointClass = dictionary?["class"] as? String
            self.region = dictionary?["region"] as? String
            self.utcOffset = dictionary?["utc_offset"] as? String
            self.verified = Int(dictionary?["verified"] as? String ?? "") as NSNumber?
            self.website = dictionary?["website"] as? String
            self.worktime = dictionary?["worktime"] as? String
            
            self.lastUpdate = dictionary?["last_update"] as? String
            
            if let contacts = dictionary?["contact"] as? [String:AnyObject] {
                dictionary?["contact"] = [contacts] as AnyObject
            }
            
            if let contactDicts = dictionary?["contact"] as? [[String:AnyObject]] {
                let contacts = contactDicts.flatMap({ item -> [String:AnyObject]? in
                    var contact = item["item"] as? [String:AnyObject]
                    contact?["id"] = nil
                    return contact })
                var result : [[String:AnyObject]] = []
                for contact in contacts {
                    if let value = contact["value"] as? String {
                        let separators = [ ",", ";" ]
                        var values = [ value ]
                        for separator in separators {
                            var v : [String] = []
                            for value in values
                            {
                                v.append(contentsOf: value.components(separatedBy: separator))
                            }
                            values = v
                        }
                        
                        values = values.map({ $0.trim() }).filter({ $0.length > 0 })
                        for phone in values {
                            var c : [String:AnyObject] = [:]
                            c["fio"] = contact["fio"]
                            c["value"] = phone as AnyObject?
                            c["type"] = contact["type"]
                            c["type_id"] = contact["type_id"]
                            result.append(c)
                        }
                    }
                }
                self.contacts = result as NSObject?
            }
            if let frequencies = dictionary?["freq"] as? [String:AnyObject] {
                dictionary?["freq"] = [frequencies] as AnyObject
            }
            if let freqDicts = dictionary?["freq"] as? [[String:AnyObject]]{
                let frequencies = freqDicts.flatMap({ item -> [String:AnyObject]? in
                    var frequency = item["item"] as? [String:AnyObject]
                    frequency?["id"] = nil
                    return frequency })
                self.frequencies = frequencies as NSObject?
            }
        } else {
            return nil
        }
    }
}
