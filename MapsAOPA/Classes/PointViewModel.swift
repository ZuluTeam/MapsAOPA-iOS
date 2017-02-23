//
//  PointViewModel.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/17/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveSwift
import Result

struct Frequency {
    let callsign : String
    let frequency : String
    let type : String?
}

struct Contact {
    let name : String?
    let type : String?
    let phone : String
}

class PointViewModel : Hashable, Equatable {
    let index : String
    var location : CLLocationCoordinate2D
    let isServiced : Bool
    let isActive : Bool
    let isMilitary : Bool
    let pointType : PointType
    
    init(point: Point) {
        self.index = point.index ?? ""
        self.location = CLLocationCoordinate2D(latitude: point.latitude?.doubleValue ?? 0, longitude: point.longitude?.doubleValue ?? 0)
        self.isServiced = point.isServiced()
        self.isActive = point.active?.boolValue ?? false
        self.isMilitary = PointBelongs(rawValue: point.belongs?.intValue ?? -1)?.isMilitary() ?? false
        self.pointType = PointType(rawValue: point.type?.intValue ?? -1) ?? .unknown
    }
    
    public var hashValue: Int {
        return self.index.hash
    }
    
    public static func ==(lhs: PointViewModel, rhs: PointViewModel) -> Bool {
        return lhs.index == rhs.index
    }
}

class PointDetailsViewModel {
    
    let index : String
    let title : String
    let elevation : Int
    let email : String?
    let website : String?
    let frequencies : [Frequency]
    let contacts : [Contact]
    let fuels : String
    let runways : [RunwayViewModel]
    let type : PointType
    
    init?(point: Point?) {
        guard let point = point, let index = point.index else {
            return nil
        }
        self.index = index
        if Settings.language == "ru" {
            self.title = "\(point.titleRu ?? "") \(point.index ?? "")/\(point.indexRu ?? "")"
        } else {
            self.title = "\(point.title ?? "") \(point.index ?? "")"
        }
        
        self.elevation = point.details?.elevation?.intValue ?? 0
        self.email = point.details?.email
        self.website = point.details?.website
        self.frequencies = (point.details?.frequencies as? [[String:String]] ?? []).flatMap({ (item) -> Frequency? in
            guard let callsign = item["callsign"], let frequency = item["freq"] else {
                return nil
            }
            return Frequency(callsign: callsign, frequency: frequency, type: item["type"])
        })
        
        self.contacts = (point.details?.contacts as? [[String:String]] ?? []).flatMap({ (item) -> Contact? in
            guard let phone = item["value"] else {
                return nil
            }
            return Contact(name: item["fio"], type: item["type"], phone: phone)
        })
        
        self.fuels = (point.fuel as? Set<Fuel> ?? Set())
            .sorted(by: { $0.type?.intValue ?? 0 < $1.type?.intValue ?? 0 })
            .flatMap({ FuelType(rawValue: $0.type?.intValue ?? 0)?.description() })
            .joined(separator: ", ")
        
        self.runways = (point.runways as? Set<Runway>)?.flatMap({ RunwayViewModel(runway: $0) }) ?? []
        self.type = PointType(rawValue: point.type?.intValue ?? -1) ?? .unknown
    }
}

class RunwayViewModel {
    let length: Int
    let lightsType: RunwayLights
    let surfaceType: RunwaySurface
    let thresholds: [CLLocationCoordinate2D]
    let title: String
    let trafficPatterns: String
    let magneticCourse: String
    let trueCourse: String
    let width: Int
    
    init?(runway: Runway?) {
        guard let runway = runway else {
            return nil
        }
        
        self.length = runway.length?.intValue ?? 0
        self.width = runway.width?.intValue ?? 0
        self.lightsType = RunwayLights(rawValue: runway.lightsType?.intValue ?? -1) ?? .unknown
        self.surfaceType = RunwaySurface(rawValue: runway.surfaceType?.intValue ?? -1) ?? .unknown
        let thresholds = (runway.thresholds as? [[String:Double]] ?? []).map({ CLLocationCoordinate2D(latitude: $0["lat"] ?? 0, longitude: $0["lon"] ?? 0) })
        self.thresholds = thresholds.count == 2 ? thresholds : []
        self.title = runway.title ?? ""
        self.trafficPatterns = runway.trafficPatterns ?? ""
        self.magneticCourse = runway.magneticCourse ?? ""
        self.trueCourse = runway.trueCourse ?? ""
    }
}
