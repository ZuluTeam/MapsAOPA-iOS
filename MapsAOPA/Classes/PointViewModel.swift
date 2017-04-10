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
import RealmSwift
import Suntimes

//struct Frequency {
//    let callsign : String
//    let frequency : String
//    let type : String?
//}
//
//struct Contact {
//    let name : String?
//    let type : String?
//    let phone : String
//}

class PointViewModel : Hashable, Equatable {
    let index : String
    var location : CLLocationCoordinate2D
    let isServiced : Bool
    let isActive : Bool
    let isMilitary : Bool
    let pointType : PointType
    let title : String
    let region : String
    let point : Point
    
    init(point: Point) {
        self.point = point
        self.index = point.index 
        self.location = point.location?.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.isServiced = point.isServiced()
        self.isActive = point.active
        self.isMilitary = PointBelongs(rawValue: point.belongs)?.isMilitary() ?? false
        self.pointType = PointType(rawValue: point.type) ?? .unknown
        
        if Settings.language == "ru" {
            self.title = "\(point.titleRu ?? "") \(point.index )/\(point.indexRu ?? "")"
        } else {
            self.title = "\(point.title ?? "") \(point.index )"
        }
        
        var region = [String]()
        if let countryId = point.details?.countryId, let country = PointCountry(rawValue: countryId) {
            region.append(country.localized)
        }
        if let pointRegion = point.details?.region {
            region.append(pointRegion.transliterated(language: Settings.language).capitalized)
        }
        if let city = point.details?.city {
            region.append(city.transliterated(language: Settings.language).capitalized)
        }
        self.region = region.joined(separator: ", ")
    }
    
    public var hashValue: Int {
        return self.index.hash
    }
    
    public static func ==(lhs: PointViewModel, rhs: PointViewModel) -> Bool {
        return lhs.index == rhs.index
    }
}

class PointDetailsViewModel {
    
    enum DetailsAction {
        case call
        case mail
        case web
    }
    
    struct TableObject {
        let text : String?
        let details : String?
        let value : String?
        let items : [(title: String, value: String)]?
        let imageURL : URL?
        let action : DetailsAction?
        
        init(text: String? = nil, details: String? = nil, value: String? = nil, items: [(title: String, value: String)]? = nil, imageURL : URL? = nil, action: DetailsAction? = nil) {
            self.text = text
            self.details = details
            self.value = value
            self.items = items
            self.imageURL = imageURL
            self.action = action
        }
    }
    
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
    let location : CLLocationCoordinate2D
    
    
    var tableViewObjects = [(sectionTitle: String?, objects: [TableObject])]()
    
    init?(point: Point?) {
        guard let point = point else {
            return nil
        }
        self.index = point.index
        if Settings.language == "ru" {
            self.title = "\(point.titleRu ?? "") \(point.index)/\(point.indexRu ?? "")"
        } else {
            self.title = "\(point.title ?? "") \(point.index)"
        }
        
        self.elevation = point.details?.pointElevation ?? 0
        self.email = point.details?.email
        self.website = point.details?.website
        
        if let freq = point.details?.frequencies {
            self.frequencies = Array(freq)
        } else {
            self.frequencies = []
        }
        
        if let contacts = point.details?.contacts {
            self.contacts = Array(contacts)
        } else {
            self.contacts = []
        }
        
        let fuel = Array(point.fuel).filter({ $0.fuelType != nil })
        
        self.fuels = fuel
            .sorted(by: { $0.type < $1.type })
            .flatMap({ $0.localized })
            .joined(separator: ", ")
        
        let runways = Array(point.runways)
        self.runways = runways.flatMap({ RunwayViewModel(runway: $0) })
        self.type = point.pointType
        self.location = point.location?.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.initializeDataSource(with: point)
    }
    
    private func initializeDataSource(with point: Point) {
        self.tableViewObjects.removeAll()
        
        // Common information
        
        var commonObjects = [TableObject]()
        
        commonObjects.append(TableObject(text: "Details_Title".localized, value: title))
        
        commonObjects.append(TableObject(text: point.active ? "Details_Active".localized : "Details_Inactive".localized))
        
        if let international = point.details?.international, international == true {
            commonObjects.append(TableObject(text: "Details_International".localized))
        }
        
        if let location = point.location?.location {
            var items = [(String, String)]()
            if let country = point.details?.pointCountry {
                items.append(("Details_Country".localized, country.localized))
            }
            if let region = point.details?.region {
                items.append(("Details_Region".localized, region.transliterated(language: Settings.language).capitalized))
            }
            if let city = point.details?.city {
                items.append(("Details_City".localized, city.transliterated(language: Settings.language).capitalized))
            }
            commonObjects.append(TableObject(text: "Details_Location".localized, value: Converter.locationString(from: location), items: items))
        }
        
        if let elevation = point.details?.pointElevation {
            commonObjects.append(
                TableObject(text: "Details_Elevation".localized,
                                    value: "\(Converter.localized(distanceInMeters: elevation)) (\(Converter.localized(pressureDegreeFromMeters: Double(elevation))))"))
        }
        
        let belongs = point.pointBelongs
        commonObjects.append(TableObject(text: "Details_Belongs".localized, value: belongs.localized))
        
        if let declination = point.details?.pointDeclination {
            commonObjects.append(TableObject(text: "Details_Declination".localized, value: String(format: "%.1f°", declination)))
        }
        
        if let location = point.location?.location, let utcOffset = point.details?.utcOffset {
            let date = Date()
            let offsetComponents = utcOffset.components(separatedBy: " ")
            if let offsetString = offsetComponents.last,
                let offset = Int(offsetString),
                let timeZone = TimeZone(secondsFromGMT: 3600 * offset) {
                
                var items = [(String,String)]()
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = timeZone
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                
                let suntimes = Suntimes(date: date, timeZone: timeZone, latitude: location.latitude, longitude: location.longitude)
                let sunrise = suntimes.sunrise
                let sunset = suntimes.sunset
                items.append(("Details_Sunrise_Sunset".localized, "\(dateFormatter.string(from: sunrise))/\(dateFormatter.string(from: sunset))"))
                let twilightsStart = suntimes.civilTwilightStart
                let twilightsEnd = suntimes.civilTwilightEnd
                items.append(("Details_Twilights".localized, "\(dateFormatter.string(from: twilightsStart))/\(dateFormatter.string(from: twilightsEnd))"))
                
                commonObjects.append(TableObject(text: "Details_Daytime".localized, items: items))
            }
        }
        
        if let utcOffset = point.details?.utcOffset {
            commonObjects.append(TableObject(text: "Details_UTC_Offcet".localized, value: utcOffset))
        }
        
        if let worktime = point.details?.worktime, !worktime.isEmpty {
            commonObjects.append(TableObject(text: "Details_Worktime".localized, details: worktime))
        }
        
        if commonObjects.count > 0 {
            self.tableViewObjects.append((sectionTitle: "Details_Common_Info".localized, objects: commonObjects))
        }
        
        // Runways
        
        var runwaysObjects = [TableObject]()
        
        for runway in point.runways {
            
            var runwayItems = [(String, String)]()
            if let title = runway.title {
                runwayItems.append(("Details_Title".localized, title))
            }
            if let length = runway.runwayLength {
                runwayItems.append(("Details_Length".localized, Converter.localized(distanceInMeters: length)))
            }
            if let width = runway.runwayWidth {
                runwayItems.append(("Details_Width".localized, Converter.localized(distanceInMeters: width)))
            }
            if let magneticCources = runway.magneticCourse {
                runwayItems.append(("Details_Magnetic_Courses".localized, magneticCources))
            }
            if let trueCources = runway.trueCourse {
                runwayItems.append(("Details_True_Courses".localized, trueCources))
            }
            if let thresholds = runway.thresholds {
                runwayItems.append(("Details_Threshold1".localized, Converter.locationString(from: thresholds.threshold1)))
                runwayItems.append(("Details_Threshold2".localized, Converter.locationString(from: thresholds.threshold2)))
            }
            if let surface = runway.runwaySurface {
                runwayItems.append(("Details_Surface".localized, surface.localized))
            }
            if let lights = runway.runwayLights {
                runwayItems.append(("Details_Lights".localized, lights.localized))
            }
            if let pattern = runway.trafficPatterns {
                runwayItems.append(("Details_Pattern".localized, pattern))
            }
            runwaysObjects.append(TableObject(items: runwayItems))
        }
        
        if runwaysObjects.count > 0 {
            self.tableViewObjects.append((sectionTitle: "Details_Runways".localized, objects: runwaysObjects))
        }
        
        // Fuel
        
        var fuelObjects = [TableObject]()
        
        var fuelItems = [(String, String)]()
        
        if point.fuel.count > 0 {
            let fuels = point.fuel.sorted(by: { $0.type < $1.type })
            for fuel in fuels {
                if let fuel = fuel.fuelType {
                    fuelItems.append((fuel.localized, "Details_Always".localized))
                }
            }
        }
        
        if point.fuelOnRequest.count > 0 {
            let fuels = point.fuelOnRequest.sorted(by: { $0.type < $1.type })
            for fuel in fuels {
                if let fuel = fuel.fuelType {
                    fuelItems.append((fuel.localized, "Details_On_Request".localized))
                }
            }
        }
        
        if fuelItems.count > 0 {
            fuelObjects.append(TableObject(text: nil, items: fuelItems))
        }
        
        if fuelObjects.count > 0 {
            self.tableViewObjects.append((sectionTitle: "Details_Fuel".localized, objects: fuelObjects))
        }
        
        // Frequencies
        
        let frequenciesObjects = self.frequencies.map({ TableObject(text: $0.type?.localized, details: $0.callsign, value: "Frequencies_Format".localized(arguments: $0.frequency)) })
        
        if frequenciesObjects.count > 0 {
            self.tableViewObjects.append((sectionTitle: "Details_Frequencies".localized, objects: frequenciesObjects))
        }
        
        // Contacts
        
        var contactsObjects = self.contacts.map({ TableObject(text: $0.type, details: $0.name, value: $0.phone, action: .call) })
        
        if let email = self.email {
            contactsObjects.append(TableObject(text: "Details_Email".localized, value: email, action: .mail))
        }
        
        if let website = self.website {
            contactsObjects.append(TableObject(text: "Details_Website".localized, value: website, action: .web))
        }
        
        if contactsObjects.count > 0 {
            self.tableViewObjects.append((sectionTitle: "Details_Contacts".localized, objects: contactsObjects))
        }
        
        
        
        // Photos
        
        if let plan = point.details?.imagePlan, let imageURL = URL(string: AOPANetwork.imageURL(for: plan)) {
            self.tableViewObjects.append((sectionTitle: "Details_Image_Plan".localized, objects: [TableObject(imageURL: imageURL)]))
        }
        if let aerial = point.details?.imageAerial, let imageURL = URL(string: AOPANetwork.imageURL(for: aerial)) {
            self.tableViewObjects.append((sectionTitle: "Details_Image_Aerial".localized, objects: [TableObject(imageURL: imageURL)]))
        }
        
    }
}

struct Thresholds {
    let latitude1 : Double
    let latitude2 : Double
    let longitude1 : Double
    let longitude2 : Double
    
    init?(_ thresholds: RunwayThresholds?) {
        guard let thresholds = thresholds else {
            return nil
        }
        self.latitude1 = thresholds.latitude1
        self.latitude2 = thresholds.latitude2
        self.longitude1 = thresholds.longitude1
        self.longitude2 = thresholds.longitude2
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
    
}

class RunwayViewModel {
    let length: Int
    let lightsType: RunwayLights
    let surfaceType: RunwaySurface
    let thresholds: Thresholds?
    let title: String
    let trafficPatterns: String
    let magneticCourse: String
    let trueCourse: String
    let width: Int
    
    init?(runway: Runway?) {
        guard let runway = runway else {
            return nil
        }
        
        self.length = runway.length
        self.width = runway.width
        self.lightsType = runway.runwayLights ?? .unknown
        self.surfaceType = runway.runwaySurface ?? .unknown
        self.thresholds = Thresholds(runway.thresholds)
        self.title = runway.title ?? ""
        self.trafficPatterns = runway.trafficPatterns ?? ""
        self.magneticCourse = runway.magneticCourse ?? ""
        self.trueCourse = runway.trueCourse ?? ""
    }
}
