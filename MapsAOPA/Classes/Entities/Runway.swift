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
            if let threshold1lat = Double(value["porog1_lat"] ?? ""),
                let threshold1lon = Double(value["porog1_lon"] ?? ""),
                let threshold2lat = Double(value["porog2_lat"] ?? ""),
                let threshold2lon = Double(value["porog2_lon"] ?? "") {
                let thresholds = [
                    [ "lat" : threshold1lat, "lon" : threshold1lon ],
                    [ "lat" : threshold2lat, "lon" : threshold2lon ]
                ]
                return thresholds as NSObject?
            }
        case Runway.Keys.lightsType.rawValue :
            return RunwayLights(code: value as? String)?.rawValue as NSNumber?
        default:
            break
        }
        return super.transformImortedValue(value, for: key)
    }
}
