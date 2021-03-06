//
//  Converter.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/22/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreLocation

class Converter {
    static let hPatoMmHg : Double = 1.33322
    static let inchesToMm : Double = 25.40
    static let metersToFeet : Double = 3.2808399
    
    static func localized(distanceInMeters meters: Int) -> String {
        switch Settings.current.units.value.distance {
        case .meter: return "Meters_Format".localized(arguments: "\(meters)")
        case .foot: return "Feet_Format".localized(arguments: "\(Int(Double(meters) * metersToFeet))")
        }
    }
    
    static func localized(pressureDegreeFromMeters meters: Double) -> String {
        let value : Double
        switch Settings.current.units.value.pressure {
        case .hPa: value = meters * 0.12015397000003249
        case .inHg: value = meters * 0.00354814470007
        case .mmHg: value = meters * 0.0901228743349
        }
        return Settings.current.units.value.pressure.localizedValue(value)
    }
    
    static func locationString(from location: CLLocationCoordinate2D) -> String {
        let latitudePrefix = location.latitude >= 0 ? "N" : "S"
        let longitudePrefix = location.longitude >= 0 ? "E" : "W"
        return String(format: "%@%.5f° %@%.5f°", latitudePrefix, location.latitude, longitudePrefix, location.longitude)
    }
}
