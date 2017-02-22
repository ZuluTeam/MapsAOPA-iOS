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
    
    convenience init?(dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Runway", in: context)
        {
            self.init(entity: entity, insertInto: context)
            self.length = Int(dictionary?["length"] as? String ?? "") as NSNumber?
            self.magneticCourse = dictionary?["kurs"] as? String
            self.surfaceType = RunwaySurface(code: dictionary?["pokr_code"] as? String).rawValue as NSNumber?
            if let threshold1lat = Double(dictionary?["porog1_lat"] as? String ?? ""),
               let threshold1lon = Double(dictionary?["porog1_lon"] as? String ?? ""),
               let threshold2lat = Double(dictionary?["porog2_lat"] as? String ?? ""),
               let threshold2lon = Double(dictionary?["porog2_lon"] as? String ?? "") {
                    let thresholds = [
                        [ "lat" : threshold1lat, "lon" : threshold1lon ],
                        [ "lat" : threshold2lat, "lon" : threshold2lon ]
                    ]
                    self.thresholds = thresholds as NSObject?
            }
            self.width = Int(dictionary?["width"] as? String ?? "") as NSNumber?
            self.lightsType = RunwayLights(code: dictionary?["lights_id"] as? String)?.rawValue as NSNumber?
            self.title = dictionary?["name"] as? String
            self.trueCourse = dictionary?["kurs_ist"] as? String
            self.trafficPatterns = dictionary?["korobochka"] as? String
        } else {
            return nil
        }
    }
}
