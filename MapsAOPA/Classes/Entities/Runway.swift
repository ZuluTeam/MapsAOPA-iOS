//
//  Runway.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

enum RunwaySurface : Int
{
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
    
    init?(code: String?)
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
        default: return nil
        }
    }
}

enum RunwayLights : Int
{
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
        default: return nil
        }
    }
}

class Runway: NSManagedObject {
    
    convenience init?(dictionary: [String:AnyObject]?, inContext context: NSManagedObjectContext)
    {
        if let entity = NSEntityDescription.entity(forEntityName: "Runway", in: context)
        {
            self.init(entity: entity, insertInto: context)
            self.length = Int(dictionary?["length"] as? String ?? "") as NSNumber?
            self.magneticCourse = dictionary?["kurs"] as? String
            self.surfaceType = RunwaySurface(code: dictionary?["pokr_code"] as? String)?.rawValue as NSNumber?
            if let threshold1lat = Double(dictionary?["porog1_lat"] as? String ?? "")
            {
                if let threshold1lon = Double(dictionary?["porog1_lon"] as? String ?? "")
                {
                    if let threshold2lat = Double(dictionary?["porog2_lat"] as? String ?? "")
                    {
                        if let threshold2lon = Double(dictionary?["porog2_lon"] as? String ?? "")
                        {
                            let thresholds = [
                                [ "lat" : threshold1lat, "lon" : threshold1lon ],
                                [ "lat" : threshold2lat, "lon" : threshold2lon ]
                            ]
                            self.thresholds = thresholds as NSObject?
                        }
                    }
                }
            }
            self.width = Int(dictionary?["width"] as? String ?? "") as NSNumber?
            self.lightsType = RunwayLights(code: dictionary?["lights_id"] as? String)?.rawValue as NSNumber?
            self.title = dictionary?["name"] as? String
            self.trueCourse = dictionary?["kurs_ist"] as? String
            self.trafficPatterns = dictionary?["korobochka"] as? String
        }
        else
        {
            return nil
        }
    }
}
