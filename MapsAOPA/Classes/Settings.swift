//
//  Config.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import ReactiveSwift

enum AppKeys : String
{
    case ApiKey = "api_key"
    case LastUpdate = "last_update"
    case LastRegion = "last_region"
    case PointsFilter = "points_filter"
    case Units = "units"
    case MapType = "map_type"
    
    enum UnitsKeys : String {
        case distance
        case pressure
        case speed
    }
}

enum PointsFilterState : Int
{
    case none
    case active
    case all
    
    var localized : String {
        return "Menu_Filter_\(self.rawValue)".localized
    }
}

struct PointsFilter
{
    var airportsState : PointsFilterState
    var heliportsState : PointsFilterState
}

enum DistanceUnits : Int {
    case meter
    case foot
    
    var localized : String {
        return "Menu_Units_Distance_\(self.rawValue)".localized
    }
}

enum PressureUnits : Int {
    case mmHg
    case hPa
    case inHg
    
    var localized : String {
        return "Menu_Units_Pressure_\(self.rawValue)".localized
    }
    
    func localizedValue(_ value: Double) -> String {
        switch self {
        case .hPa: return "hPa_Format".localized(arguments: value)
        case .inHg: return "inHg_Format".localized(arguments: value)
        case .mmHg: return "mmHg_Format".localized(arguments: value)
        }
    }
}

enum SpeedUnits : Int {
    case mps
    case kmph
    case mph
    case kt
    
    var localized : String {
        return "Menu_Units_Speed_\(self.rawValue)".localized
    }
}

class Settings
{
    static let current = Settings()
    
// MARK: - Reload
    static let reloadDataTimeInterval : TimeInterval = 7 * 24 * 60 * 60
    let lastUpdate : MutableProperty<Date> = {
        let date = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: AppKeys.LastUpdate.rawValue))
        return MutableProperty(date)
    }()
    
// MARK: - Map
    static let defaultCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.75, longitude: 37.616667) // Moscow
    
    let mapType : MutableProperty<MKMapType> = {
        let mapTypeRaw = UserDefaults.standard.integer(forKey: AppKeys.MapType.rawValue)
        let mapType = MKMapType(rawValue: UInt(mapTypeRaw)) ?? .standard
        return MutableProperty(mapType)
    }()
    
    func mapRegion(withDefaultCoordinate coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion
    {
        if let regionDict = UserDefaults.standard.object(forKey: AppKeys.LastRegion.rawValue) as? [String:Double]
        {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: regionDict["lat"] ?? 0, longitude: regionDict["lon"] ?? 0),
                                      span: MKCoordinateSpan(latitudeDelta: regionDict["lat_delta"] ?? 0.2, longitudeDelta: regionDict["lon_delta"] ?? 0.2))
        }
        return MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    func saveRegion(_ region: MKCoordinateRegion)
    {
        let regionDict = [
            "lat" : region.center.latitude,
            "lon" : region.center.longitude,
            "lat_delta" : region.span.latitudeDelta,
            "lon_delta" : region.span.longitudeDelta
        ]
        UserDefaults.standard.set(regionDict, forKey: AppKeys.LastRegion.rawValue)
        UserDefaults.standard.synchronize()
    }
    
// MARK: - Points
    
    let pointsFilter : MutableProperty<PointsFilter> = {
        let filter = UserDefaults.standard.object(forKey: AppKeys.PointsFilter.rawValue) as? [String:AnyObject]
        return MutableProperty(PointsFilter(airportsState:
            PointsFilterState(rawValue: filter?["a_state"] as? Int ?? PointsFilterState.active.rawValue) ?? .active,
                            heliportsState:
            PointsFilterState(rawValue: filter?["h_state"] as? Int ?? PointsFilterState.none.rawValue) ?? .none))
    }()
    
// MARK: - Units
    
    struct Units {
        var distance : DistanceUnits = { return (Settings.language == "ru") ? .meter : .foot }()
        var pressure : PressureUnits = { return (Settings.language == "ru" ? .mmHg : .hPa) }()
        var speed : SpeedUnits = { return (Settings.language == "ru" ? .kmph : .kt) }()
    }
    
    let units : MutableProperty<Units> = {
        var units = Units()
        if let unitsDict = UserDefaults.standard.object(forKey: AppKeys.Units.rawValue) as? [String:Int] {
            if let distanceValue = unitsDict[AppKeys.UnitsKeys.distance.rawValue], let distance = DistanceUnits(rawValue: distanceValue) {
                units.distance = distance
            }
            if let pressureValue = unitsDict[AppKeys.UnitsKeys.pressure.rawValue], let pressure = PressureUnits(rawValue: pressureValue) {
                units.pressure = pressure
            }
            if let speedValue = unitsDict[AppKeys.UnitsKeys.speed.rawValue], let speed = SpeedUnits(rawValue: speedValue) {
                units.speed = speed
            }
        }
        return MutableProperty(units)
    }()
    
// MARK: - Language
    
    static var language : String {
        if let language = NSLocale.preferredLanguages.first {
            let languageDict = NSLocale.components(fromLocaleIdentifier: language)
            return languageDict["kCFLocaleLanguageCodeKey"] ?? "en"
        }
        return "en"
    }
    
// MARK: - Initialization
    
    private init() {
        self.mapType.producer.startWithValues { mapType in
            UserDefaults.standard.set(mapType.rawValue, forKey: AppKeys.MapType.rawValue)
            UserDefaults.standard.synchronize()
        }
        self.lastUpdate.producer.startWithValues { date in
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: AppKeys.LastUpdate.rawValue)
            UserDefaults.standard.synchronize()
        }
        self.units.producer.startWithValues { units in
            let unitsDict = [
                AppKeys.UnitsKeys.distance.rawValue : units.distance.rawValue,
                AppKeys.UnitsKeys.pressure.rawValue : units.pressure.rawValue,
                AppKeys.UnitsKeys.speed.rawValue : units.speed.rawValue,
                ]
            UserDefaults.standard.set(unitsDict, forKey: AppKeys.Units.rawValue)
            UserDefaults.standard.synchronize()
        }
        self.pointsFilter.producer.startWithValues { pointsFilter in
            let filter = [
                "a_state" : pointsFilter.airportsState.rawValue,
                "h_state" : pointsFilter.heliportsState.rawValue
            ]
            UserDefaults.standard.set(filter, forKey: AppKeys.PointsFilter.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
