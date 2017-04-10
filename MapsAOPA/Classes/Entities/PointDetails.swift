//
//  PointDetails.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

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
    
    var localized : String {
        return "country_\(self.rawValue)".localized
    }
}

class Contact: Object, Mappable {
    dynamic var type : String? = nil
    dynamic var phone : String = ""
    dynamic var name : String? = nil
    
    fileprivate enum Keys : String {
        case name = "fio"
        case phone = "value"
        case type = "type"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        type <- map[Keys.type.rawValue]
        phone <- map[Keys.phone.rawValue, ignoreNil: true]
        name <- map[Keys.name.rawValue]
    }
}

class Frequency: Object, Mappable {
    dynamic var callsign : String = ""
    dynamic var frequency : String = ""
    dynamic var type : String? = nil
    
    fileprivate enum Keys : String {
        case frequency = "freq"
        case callsign
        case type
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        callsign <- map[Keys.callsign.rawValue, ignoreNil: true]
        frequency <- map[Keys.frequency.rawValue, ignoreNil: true]
        type <- map[Keys.type.rawValue]
    }
    
    private var callsignTransform : TransformJSONOf<String, String> {
        return TransformJSONOf(fromJSON: { (value) -> String? in
            return value?.transliterated(language: Settings.language).capitalized
        })
    }
}

class PointDetails: Object, Mappable {
    
    dynamic var elevation = Int.max
    dynamic var city: String? = nil
    dynamic var comment: String? = nil
    var contacts = List<Contact>()
    dynamic var countryId = -1
    dynamic var countryName: String? = nil
    dynamic var declination: Float = Float.greatestFiniteMagnitude
    dynamic var email: String? = nil
    var frequencies = List<Frequency>()
    dynamic var imageAerial: String? = nil
    dynamic var imagePlan: String? = nil
    dynamic var infrastructure: String? = nil
    dynamic var international = false
    dynamic var lastUpdate: String? = nil
    dynamic var pointClass: String? = nil
    dynamic var region: String? = nil
    dynamic var utcOffset: String? = nil
    dynamic var verified = false
    dynamic var website: String? = nil
    dynamic var worktime: String? = nil
    dynamic var point: Point? = nil

    
    fileprivate enum Keys : String {
        case city
        case comment = "comments"
        case contacts = "contact"
        case countryId = "country_id"
        case countryName = "country_name"
        case declination = "delta_m"
        case elevation = "height"
        case email
        case frequencies = "freq"
        case imageAerial = "img_aerial"
        case imagePlan = "img_plan"
        case infrastructure
        case international
        case lastUpdate = "last_update"
        case pointClass = "class"
        case region
        case utcOffset = "utc_offset"
        case verified
        case website
        case worktime
    }
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        elevation <- (map[Keys.elevation.rawValue, ignoreNil: true], TransformIntValue())
        city <- map[Keys.city.rawValue]
        comment <- map[Keys.comment.rawValue]
        contacts <- (map[Keys.contacts.rawValue], contactsTransform)
        countryId <- (map[Keys.countryId.rawValue, ignoreNil: true], countryIdTransform)
        countryName <- map[Keys.countryName.rawValue]
        declination <- map[Keys.declination.rawValue, ignoreNil: true]
        email <- map[Keys.email.rawValue]
        frequencies <- (map[Keys.frequencies.rawValue], frequenciesTransform)
        imageAerial <- map[Keys.imageAerial.rawValue]
        imagePlan <- map[Keys.imagePlan.rawValue]
        infrastructure <- map[Keys.infrastructure.rawValue]
        international <- (map[Keys.international.rawValue, ignoreNil: true], TransformBoolValue())
        lastUpdate <- map[Keys.lastUpdate.rawValue]
        pointClass <- map[Keys.pointClass.rawValue]
        region <- map[Keys.region.rawValue]
        utcOffset <- map[Keys.utcOffset.rawValue]
        verified <- (map[Keys.verified.rawValue], TransformBoolValue())
        website <- map[Keys.website.rawValue]
        worktime <- map[Keys.worktime.rawValue]
    }
    
    var pointCountry : PointCountry? {
        return PointCountry(rawValue: countryId)
    }
    
    var pointElevation : Int? {
        if self.elevation != Int.max {
            return self.elevation
        }
        return nil
    }
    
    var pointDeclination : Float? {
        if self.declination < Float.greatestFiniteMagnitude {
            return self.declination
        }
        return nil
    }
}

extension PointDetails {
    
    fileprivate var countryIdTransform : TransformJSONOf<Int, String> {
        return TransformJSONOf(fromJSON: { (value: String?) -> Int? in
            return PointCountry(code: value)?.rawValue
        })
    }
    
    fileprivate var frequenciesTransform : TransformPointArrayContent<List<Frequency>> {
        return TransformPointArrayContent(fromJSON: { (value) -> List<Frequency> in
            if let freqDicts = value {
                let frequencies = freqDicts.flatMap({ item -> [String:AnyObject]? in
                    var frequency = item["item"] as? [String:AnyObject]
                    frequency?["id"] = nil
                    return frequency
                })
                
                if let objects = Mapper<Frequency>().mapArray(JSONObject: frequencies) {
                    let list = List<Frequency>()
                    list.append(objectsIn: objects)
                    return list
                }
            }
            return List<Frequency>()
        })
    }
    
    fileprivate var contactsTransform : TransformPointArrayContent<List<Contact>> {
        return TransformPointArrayContent(fromJSON: { (value) -> List<Contact> in
            
            var result : [[String:AnyObject]] = []
            if let contactDicts = value {
                let contacts = contactDicts.flatMap({ item -> [String:AnyObject]? in
                    var contact = item["item"] as? [String:AnyObject]
                    contact?["id"] = nil
                    return contact
                })
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
            }
            
            if let objects = Mapper<Contact>().mapArray(JSONObject: result) {
                let list = List<Contact>()
                list.append(objectsIn: objects)
                return list
            }
            return List<Contact>()
        })
    }
}

