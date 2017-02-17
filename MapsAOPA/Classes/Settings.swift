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

enum AppKeys : String
{
    case ApiKey = "api_key"
    case LastUpdate = "last_update"
    case LastRegion = "last_region"
    case PointsFilter = "points_filter"
}

enum PointsFilterState : Int
{
    case none
    case active
    case all
}

struct PointsFilter
{
    var airportsState : PointsFilterState
    var heliportsState : PointsFilterState
}

class Settings
{
    static let reloadDataTimeInterval : TimeInterval = 7 * 24 * 60 * 60
    
    static var pointsFilter : PointsFilter = {
        let filter = UserDefaults.standard.object(forKey: AppKeys.PointsFilter.rawValue) as? [String:AnyObject]
        return PointsFilter(airportsState:
            PointsFilterState(rawValue: filter?["a_state"] as? Int ?? PointsFilterState.active.rawValue) ?? .active,
                            heliportsState:
            PointsFilterState(rawValue: filter?["h_state"] as? Int ?? PointsFilterState.none.rawValue) ?? .none)
    }()
    {
        didSet {
            let filter = [
                "a_state" : pointsFilter.airportsState.rawValue,
                "h_state" : pointsFilter.heliportsState.rawValue
            ]
            UserDefaults.standard.set(filter, forKey: AppKeys.PointsFilter.rawValue)
        }
    }
    
    static var lastUpdate : Date = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: AppKeys.LastUpdate.rawValue))
    {
        didSet {
            
            UserDefaults.standard.set(lastUpdate.timeIntervalSince1970, forKey: AppKeys.LastUpdate.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static let defaultCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.75, longitude: 37.616667)
    
    static func mapRegion(withDefaultCoordinate coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion
    {
        if let regionDict = UserDefaults.standard.object(forKey: AppKeys.LastRegion.rawValue) as? [String:Double]
        {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: regionDict["lat"] ?? 0, longitude: regionDict["lon"] ?? 0),
                                      span: MKCoordinateSpan(latitudeDelta: regionDict["lat_delta"] ?? 0.2, longitudeDelta: regionDict["lon_delta"] ?? 0.2))
        }
        return MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    static func saveRegion(_ region: MKCoordinateRegion)
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
    
    static var language : String {
        if let language = NSLocale.preferredLanguages.first {
            let languageDict = NSLocale.components(fromLocaleIdentifier: language)
            return languageDict["kCFLocaleLanguageCodeKey"] ?? "en"
        }
        return "en"
    }
}
