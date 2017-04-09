//
//  Runway.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData
import UIColor_Hex_Swift
import CoreLocation
import RealmSwift
import ObjectMapper

enum RunwaySurface : Int
{
    case unknown = -1
    case water = 0
    case soft
    case softDirt
    case softGravel
    case hard
    case hardAsphalt
    case hardArmoredConcrete
    case hardConcrete
    case hardBituminusConcrete
    case hardMetal
    case hardCement
    
    init(code: String?)
    {
        switch code ?? ""
        {
        case "water" : self = .water
            case "soft": self = .soft
            case "dirt": self = .softDirt
            case "gravel": self = .softGravel
            case "hard": self = .hard
            case "hard-asphalt": self = .hardAsphalt
            case "hard-armored-concrete": self = .hardArmoredConcrete
            case "hard-concrete": self = .hardConcrete
            case "hard-bituminous-concrete": self = .hardBituminusConcrete
            case "hard-metal": self = .hardMetal
            case "hard-cement": self = .hardCement
        default: self = .unknown
        }
    }
    
    var color : UIColor {
        let aplha : CGFloat = 0.7
        switch self {
        case .water: return UIColor(hexString: "6495ED").withAlphaComponent(aplha)
        case .soft: return UIColor(hexString: "66CDAA").withAlphaComponent(aplha)
        case .softDirt: return UIColor(hexString: "808000").withAlphaComponent(aplha)
        case .softGravel: return UIColor(hexString: "DCDCDC").withAlphaComponent(aplha)
        case .hard: return UIColor(hexString: "A9A9A9").withAlphaComponent(aplha)
        case .hardAsphalt: return UIColor(hexString: "708090").withAlphaComponent(aplha)
        case .hardArmoredConcrete: return UIColor(hexString: "A9A9A9").withAlphaComponent(aplha)
        case .hardConcrete: return UIColor(hexString: "A9A9A9").withAlphaComponent(aplha)
        case .hardBituminusConcrete: return UIColor(hexString: "A9A9A9").withAlphaComponent(aplha)
        case .hardMetal: return UIColor(hexString: "778899").withAlphaComponent(aplha)
        case .hardCement: return UIColor(hexString: "A9A9A9").withAlphaComponent(aplha)
        default: return UIColor(hexString: "66CDAA").withAlphaComponent(aplha)
        }
    }
    
    var localized : String {
        return "runway_surface_\(self.rawValue)".localized
    }
}

enum RunwayLights : Int
{
    case unknown = -1
    case none = 0
    case always
    case onRequest
    case pilotControlled
    
    init?(code: String?)
    {
        switch code ?? ""
        {
        case "1": self = .none
        case "2": self = .always
        case "3": self = .onRequest
        case "4": self = .pilotControlled
        default: self = .unknown
        }
    }
    
    var localized : String {
        return "runway_lights_\(self.rawValue)".localized
    }
}

class Runway: Object, Mappable {
    dynamic var length = 0
    dynamic var lightsType = -1
    dynamic var magneticCourse: String?
    dynamic var surfaceType = -1
    dynamic var title: String?
    dynamic var trafficPatterns: String?
    dynamic var trueCourse: String?
    dynamic var width = 0
    
    dynamic var thresholds: RunwayThresholds?
    dynamic var point: Point?
    
    fileprivate enum Keys : String {
        case length
        case lightsType = "lights_id"
        case magneticCourse = "kurs"
        case surfaceType = "pokr_code"
        case title = "name"
        case trafficPatterns = "korobochka"
        case trueCourse = "kurs_ist"
        case width
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        length <- (map[Keys.length.rawValue, ignoreNil: true], TransformIntValue())
        lightsType <- (map[Keys.lightsType.rawValue, ignoreNil: true], lightsTypeTransform)
        magneticCourse <- map[Keys.magneticCourse.rawValue]
        surfaceType <- (map[Keys.surfaceType.rawValue, ignoreNil: true], surfaceTransform)
        title <- map[Keys.title.rawValue]
        trafficPatterns <- map[Keys.trafficPatterns.rawValue]
        trueCourse <- map[Keys.trueCourse.rawValue]
        width <- (map[Keys.width.rawValue], TransformIntValue())
        
        thresholds = Mapper<RunwayThresholds>().map(JSON: map.JSON)
    }
    
    var runwayLength : Int? {
        if length != 0 {
            return length
        }
        return nil
    }
    
    var runwayWidth : Int? {
        if width != 0 {
            return width
        }
        return nil
    }
    
    var runwayLights : RunwayLights? {
        if let lights = RunwayLights(rawValue: self.lightsType), lights != .unknown {
            return lights
        }
        return nil
    }
    
    var runwaySurface : RunwaySurface? {
        if let surface = RunwaySurface(rawValue: self.surfaceType), surface != .unknown {
            return surface
        }
        return nil
    }
    
}

extension Runway {
    
    fileprivate var surfaceTransform : TransformJSONOf<Int, String> {
        return TransformJSONOf(fromJSON: { (value: String?) -> Int? in
            return RunwaySurface(code: value).rawValue
        })
    }
    
    fileprivate var lightsTypeTransform : TransformJSONOf<Int, String> {
        return TransformJSONOf(fromJSON: { (value: String?) -> Int? in
            return RunwayLights(code: value)?.rawValue
        })
    }
}

class RunwayThresholds : Object, Mappable {
    dynamic var latitude1 = 0.0
    dynamic var latitude2 = 0.0
    dynamic var longitude1 = 0.0
    dynamic var longitude2 = 0.0
    
    fileprivate enum Keys : String {
        case latitude1 = "porog1_lat"
        case latitude2 = "porog2_lat"
        case longitude1 = "porog1_lon"
        case longitude2 = "porog2_lon"
    }
    
    var threshold1 : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude1, longitude: longitude1)
        }
    }
    var threshold2 : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude2, longitude: longitude2)
        }
    }
        
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        latitude1 <- map[Keys.latitude1.rawValue, ignoreNil: true]
        latitude2 <- map[Keys.latitude2.rawValue, ignoreNil: true]
        longitude1 <- map[Keys.longitude1.rawValue, ignoreNil: true]
        longitude2 <- map[Keys.longitude2.rawValue, ignoreNil: true]
    }
}
