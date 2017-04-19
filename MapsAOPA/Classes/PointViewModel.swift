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
import CoreData
import Suntimes

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
    let title : String
    let region : String
    let pointID : NSManagedObjectID
    var _point : Point?
    
    var point : Point? {
        get {
            if _point == nil {
                if let point = try? Database.sharedDatabase.managedObjectContext.existingObject(with: pointID) as? Point {
                    _point = point
                }
            }
            return _point
        }
    }
    
    
    init(point: Point) {
        self.pointID = point.objectID
        self.index = point.index ?? ""
        self.location = point.location?.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.isServiced = point.isServiced()
        self.isActive = point.active?.boolValue ?? false
        self.isMilitary = PointBelongs(rawValue: point.belongs?.intValue ?? -1)?.isMilitary() ?? false
        self.pointType = PointType(rawValue: point.type?.intValue ?? -1) ?? .unknown
        
        if Settings.language == "ru" {
            self.title = "\(point.titleRu ?? "") \(point.index ?? "")/\(point.indexRu ?? "")"
        } else {
            self.title = "\(point.title ?? "") \(point.index ?? "")"
        }
        
        var region = [String]()
        if let countryId = point.details?.countryId?.intValue, let country = PointCountry(rawValue: countryId) {
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
            return Frequency(callsign: callsign.transliterated(language: Settings.language).capitalized,
                             frequency: frequency,
                             type: item["type"])
        })
        
        self.contacts = (point.details?.contacts as? [[String:String]] ?? []).flatMap({ (item) -> Contact? in
            guard let phone = item["value"] else {
                return nil
            }
            return Contact(name: item["fio"]?.transliterated(language: Settings.language).capitalized,
                           type: item["type"]?.transliterated(language: Settings.language).capitalized,
                           phone: phone.replace(" ", with: ""))
        })
        
        self.fuels = (point.fuel as? Set<Fuel> ?? Set())
            .sorted(by: { $0.type?.intValue ?? 0 < $1.type?.intValue ?? 0 })
            .flatMap({ FuelType(rawValue: $0.type?.intValue ?? 0)?.localized })
            .joined(separator: ", ")
        
        self.runways = (point.runways as? Set<Runway>)?.flatMap({ RunwayViewModel(runway: $0) }) ?? []
        self.type = PointType(rawValue: point.type?.intValue ?? -1) ?? .unknown
        self.location = point.location?.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.initializeDataSource(with: point)
    }
    
    private func initializeDataSource(with point: Point) {
        self.tableViewObjects.removeAll()
        
        // Common information
        
        var commonObjects = [TableObject]()
        
        commonObjects.append(TableObject(text: "Details_Title".localized, value: title))
        
        if let active = point.active?.boolValue {
            commonObjects.append(TableObject(text: active ? "Details_Active".localized : "Details_Inactive".localized))
        }
        
        if let international = point.details?.international?.boolValue, international {
            commonObjects.append(TableObject(text: "Details_International".localized))
        }
        
        if let location = point.location?.location {
            var items = [(String, String)]()
            if let countryId = point.details?.countryId?.intValue, let country = PointCountry(rawValue: countryId) {
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
        
        if let elevation = point.details?.elevation?.intValue {
            commonObjects.append(
                TableObject(text: "Details_Elevation".localized,
                                    value: "\(Converter.localized(distanceInMeters: elevation)) (\(Converter.localized(pressureDegreeFromMeters: Double(elevation))))"))
        }
        
        if let belongsId = point.belongs?.intValue, let belongs = PointBelongs(rawValue: belongsId) {
            commonObjects.append(TableObject(text: "Details_Belongs".localized, value: belongs.localized))
        }
        
        if let declination = point.details?.declination?.floatValue {
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
        
        if let runways = point.runways as? Set<Runway>
        {
            for runway in runways {
                
                var runwayItems = [(String, String)]()
                if let title = runway.title {
                    runwayItems.append(("Details_Title".localized, title))
                }
                if let length = runway.length?.intValue {
                    runwayItems.append(("Details_Length".localized, Converter.localized(distanceInMeters: length)))
                }
                if let width = runway.width?.intValue {
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
                if let surfaceType = runway.surfaceType?.intValue, let surface = RunwaySurface(rawValue: surfaceType), surface != .unknown {
                    runwayItems.append(("Details_Surface".localized, surface.localized))
                }
                if let lightsType = runway.lightsType?.intValue, let lights = RunwayLights(rawValue: lightsType), lights != .unknown {
                    runwayItems.append(("Details_Lights".localized, lights.localized))
                }
                if let pattern = runway.trafficPatterns {
                    runwayItems.append(("Details_Pattern".localized, pattern))
                }
                runwaysObjects.append(TableObject(items: runwayItems))
            }
        }
        
        if runwaysObjects.count > 0 {
            self.tableViewObjects.append((sectionTitle: "Details_Runways".localized, objects: runwaysObjects))
        }
        
        // Fuel
        
        var fuelObjects = [TableObject]()
        
        var fuelItems = [(String, String)]()
        
        if let fuels = (point.fuel as? Set<Fuel>)?.sorted(by: { $0.0.type?.intValue ?? 0 < $0.1.type?.intValue ?? 0 }) {
            for fuel in fuels {
                if let fuelTypeRaw = fuel.type?.intValue, let fuel = FuelType(rawValue: fuelTypeRaw) {
                    fuelItems.append((fuel.localized, "Details_Always".localized))
                }
            }
        }
        
        if let fuels = (point.fuelOnRequest as? Set<Fuel>)?.sorted(by: { $0.0.type?.intValue ?? 0 < $0.1.type?.intValue ?? 0 }) {
            for fuel in fuels {
                if let fuelTypeRaw = fuel.type?.intValue, let fuel = FuelType(rawValue: fuelTypeRaw) {
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

class RunwayViewModel {
    let length: Int
    let lightsType: RunwayLights
    let surfaceType: RunwaySurface
    let thresholds: RunwayThresholds?
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
        self.thresholds = runway.thresholds
        self.title = runway.title ?? ""
        self.trafficPatterns = runway.trafficPatterns ?? ""
        self.magneticCourse = runway.magneticCourse ?? ""
        self.trueCourse = runway.trueCourse ?? ""
    }
}
