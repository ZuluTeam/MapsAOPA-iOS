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
        case "1" : self = .none
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

class Runway: NSManagedObject {
    fileprivate enum Keys : String {
        case surfaceType
        case thresholds
        case lightsType
    }
}

extension Runway: Managed {
    
    public static var entityName : String {
        return "Runway"
    }
    
}

extension Runway {
    
    static func registerValueTransformers() {
        let locationTransform = "ThresholdsTransform"
        
        ValueTransform<RunwayThresholds, NSData>.registerValueTransformerWithName(locationTransform, transform: { (thresholds : RunwayThresholds?) -> NSData? in
            guard let thresholds = thresholds else {
                return nil
            }
            return NSKeyedArchiver.archivedData(withRootObject: thresholds) as NSData
        }, reverseTransform: { (data: NSData?) -> RunwayThresholds? in
            guard let data = data else {
                return nil
            }
            return NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? RunwayThresholds
        })
        
    }
    
}


extension Runway {
    
    override func transformImortedValue(_ value: Any, for key: String) -> NSObject? {
        switch key {
        case Runway.Keys.surfaceType.rawValue :
            if let value = value as? String {
                return RunwaySurface(code: value).rawValue as NSNumber?
            }
        case Runway.Keys.thresholds.rawValue :
            guard let value = value as? [String : String] else {
                return nil
            }
            if let threshold1lat = Double(value["porog1_lat"] ?? "0"),
                let threshold1lon = Double(value["porog1_lon"] ?? "0"),
                let threshold2lat = Double(value["porog2_lat"] ?? "0"),
                let threshold2lon = Double(value["porog2_lon"] ?? "0") {
                
                if threshold1lat != 0 && threshold2lat != 0 && threshold1lon != 0 && threshold2lon != 0 {
                    let thresholds = RunwayThresholds(threshold1: CLLocationCoordinate2D(latitude: threshold1lat, longitude: threshold1lon), threshold2: CLLocationCoordinate2D(latitude: threshold2lat, longitude: threshold2lon))
                    return thresholds as NSObject?
                }
            }
            return nil
        case Runway.Keys.lightsType.rawValue :
            return RunwayLights(code: value as? String)?.rawValue as NSNumber?
        default:
            break
        }
        return super.transformImortedValue(value, for: key)
    }
}

@objc class RunwayThresholds : NSObject, NSCoding {
    
    private enum CodingKey : String {
        case latitude1
        case longitude1
        case latitude2
        case longitude2
    }
    
    let threshold1 : CLLocationCoordinate2D
    let threshold2 : CLLocationCoordinate2D
    init(threshold1: CLLocationCoordinate2D, threshold2: CLLocationCoordinate2D) {
        self.threshold1 = threshold1
        self.threshold2 = threshold2
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let latitude1 = aDecoder.decodeDouble(forKey: CodingKey.latitude1.rawValue)
        let longitude1 = aDecoder.decodeDouble(forKey: CodingKey.longitude1.rawValue)
        let latitude2 = aDecoder.decodeDouble(forKey: CodingKey.latitude2.rawValue)
        let longitude2 = aDecoder.decodeDouble(forKey: CodingKey.longitude2.rawValue)
        
        self.threshold1 = CLLocationCoordinate2D(latitude: latitude1, longitude: longitude1)
        self.threshold2 = CLLocationCoordinate2D(latitude: latitude2, longitude: longitude2)
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(threshold1.latitude, forKey: CodingKey.latitude1.rawValue)
        aCoder.encode(threshold1.longitude, forKey: CodingKey.longitude1.rawValue)
        aCoder.encode(threshold2.latitude, forKey: CodingKey.latitude2.rawValue)
        aCoder.encode(threshold2.longitude, forKey: CodingKey.longitude2.rawValue)
    }
}
