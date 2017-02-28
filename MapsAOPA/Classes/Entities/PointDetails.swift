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
    fileprivate enum Keys : String {
        case countryId
        case contacts
        case frequencies
    }
}

extension PointDetails: Managed {
    
    public static var entityName : String {
        return "PointDetails"
    }
    
    public static var defaultSortDescriptors : [NSSortDescriptor] {
        return []
    }
    
}

extension PointDetails {
    
    override func transformImortedValue(_ value: Any, for key: String) -> NSObject? {
        switch key {
        case PointDetails.Keys.countryId.rawValue :
            if let value = value as? String {
                return PointCountry(code: value)?.rawValue as NSObject?
            }
        case PointDetails.Keys.contacts.rawValue :
            var dictionary = value as? [[String:AnyObject]]
            if let contactsDict = value as? [String:AnyObject] {
                dictionary = [contactsDict]
            }
            if let contactDicts = dictionary {
                let contacts = contactDicts.flatMap({ item -> [String:AnyObject]? in
                    var contact = item["item"] as? [String:AnyObject]
                    contact?["id"] = nil
                    return contact
                })
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
                return result as NSObject?
            }
            return nil
        case PointDetails.Keys.frequencies.rawValue :
            var dictionary = value as? [[String:AnyObject]]
            if let freqDict = value as? [String: AnyObject] {
                dictionary = [freqDict]
            }
            if let freqDicts = dictionary {
                let frequencies = freqDicts.flatMap({ item -> [String:AnyObject]? in
                    var frequency = item["item"] as? [String:AnyObject]
                    frequency?["id"] = nil
                    return frequency
                })
                return frequencies as NSObject?
            }
            return nil
        default:
            break
        }
        return super.transformImortedValue(value, for: key)
    }
}

