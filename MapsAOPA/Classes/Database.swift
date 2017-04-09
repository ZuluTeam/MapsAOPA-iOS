//
//  Database.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import CoreData
import ReactiveSwift
import MapKit

class Database
{
    static let sharedDatabase = Database()
    
    fileprivate init() { }
    
    static func pointsPredicate(forRegion region: MKCoordinateRegion, withFilter filter: PointsFilter) -> NSPredicate
    {
        var format =
            "\(Point.Keys.latitude.rawValue) >= \(region.center.latitude - region.span.latitudeDelta) AND " +
            "\(Point.Keys.longitude.rawValue) >= \(region.center.longitude - region.span.longitudeDelta) AND " +
            "\(Point.Keys.latitude.rawValue) <= \(region.center.latitude + region.span.latitudeDelta) AND " +
            "\(Point.Keys.longitude.rawValue) <= \(region.center.longitude + region.span.longitudeDelta)"
        
        let airportsFormat : String
        var connection : String = "OR"
        switch filter.airportsState {
        case .all: airportsFormat = "(\(Point.Keys.type.rawValue) = \(PointType.airport.rawValue))"
        case .active: airportsFormat = "(\(Point.Keys.type.rawValue) = \(PointType.airport.rawValue) AND \(Point.Keys.active.rawValue) = 1)"
        case .none: airportsFormat = "(\(Point.Keys.type.rawValue) != \(PointType.airport.rawValue))"; connection = "AND"
        }
        
        let heliportsFormat : String
        switch filter.heliportsState {
        case .all: heliportsFormat = "(\(Point.Keys.type.rawValue) = \(PointType.heliport.rawValue))"
        case .active: heliportsFormat = "(\(Point.Keys.type.rawValue) = \(PointType.heliport.rawValue) AND \(Point.Keys.active.rawValue) = 1)"
        case .none: heliportsFormat = "(\(Point.Keys.type.rawValue) != \(PointType.heliport.rawValue))"; connection = "AND"
        }
        
        format += " AND (\(airportsFormat) \(connection) \(heliportsFormat))"

        return NSPredicate(format: format, argumentArray: nil)
    }
}
