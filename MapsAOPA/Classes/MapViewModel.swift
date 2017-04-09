//
//  MapViewModel.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/20/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import MapKit
import ReactiveSwift
import Result
import MapKit
import RealmSwift
import ObjectMapper

class MapViewModel
{
    var isLoading : ReactiveSwift.Property<Bool> { return Property(_loading) }
    var errorMessage : ReactiveSwift.Property<String?> { return Property(_errorMessage) }
    
    var mapRegion = Settings.current.mapRegion(withDefaultCoordinate: Settings.defaultCoordinate) {
        didSet {
            self.updateRegion(mapRegion, withFilter: self.pointsFilter)
        }
    }
    var mapPoints : ReactiveSwift.Property<[PointViewModel]> { return Property(_mapPoints) }
    var foundedPoints : ReactiveSwift.Property<[PointViewModel]> { return Property(_foundedPoints) }
    
    var selectedPoint = MutableProperty<PointViewModel?>(nil)
    
    fileprivate let _loading = MutableProperty<Bool>(false)
    fileprivate let _errorMessage = MutableProperty<String?>(nil)
    
    fileprivate let _mapPoints = MutableProperty<[PointViewModel]>([])
    fileprivate let _foundedPoints = MutableProperty<[PointViewModel]>([])
    
    fileprivate let network : Network
    fileprivate let loader : AOPALoader
    
    fileprivate var xmlParser : ArrayXMLParser?
    
    fileprivate var searchString : String?
    
    fileprivate var pointsFilter : PointsFilter = Settings.current.pointsFilter.value
    
    init() {
        self.network = Network()
        self.loader = AOPALoader(network: network)
        
        Settings.current.pointsFilter.producer.startWithValues { [weak self] filter in
            if let selfInstance = self {
                selfInstance.pointsFilter = filter
                selfInstance.updateRegion(selfInstance.mapRegion, withFilter: filter)
            }
        }
    }
    
    func loadAirfields(force: Bool = false) {
        if _loading.value {
            return
        }
        let date = Date()
        if !force && date.timeIntervalSince(Settings.current.lastUpdate.value) < Settings.reloadDataTimeInterval {
            return
        }
        _loading.value = true
        
        self.loader.loadAirfields().flatMap(.latest, transform: { [weak self] (url : URL) -> SignalProducer<Any, AOPAError> in
            self?.xmlParser = ArrayXMLParser(contentsOf: url, forItems: "point")
            if let xmlParser = self?.xmlParser {
                return xmlParser.parse().mapError({ AOPAError($0) })
            }
            return .empty
        }).on(failed: { [weak self] error in
            print(error.description)
            self?._errorMessage.value = error.description
            },
              completed: { [weak self] in
                self?.xmlParser = nil
                self?._loading.value = false
                Settings.current.lastUpdate.value = Date()
                if let selfInstance = self {
                    selfInstance.updateRegion(selfInstance.mapRegion, withFilter: selfInstance.pointsFilter)
                }
                print("Complete savings")
            },
              value: { value in
                if let pointDict = value as? [String:AnyObject] {
                
                    let realm = try! Realm()
                    if let point = Mapper<Point>().map(JSON: pointDict) {
                        try! realm.write {
                            realm.add(point, update: true)
                        }
                    }
                }
        }).start()
    }
    
    private func updateRegion(_ region: MKCoordinateRegion, withFilter filter: PointsFilter) {
        Settings.current.saveRegion(region)
        let predicate = Database.pointsPredicate(forRegion: region, withFilter: filter)
        
        let points = Point.pointsWith(predicate: predicate)
        
        var pointModels = points.map({
            PointViewModel(point: $0)
        })
        if let selectedPoint = self.selectedPoint.value {
            pointModels.append(selectedPoint)
        }
        
        self._mapPoints.value = pointModels
    }
    
    func pointDetailsViewModel(from pointViewModel: PointViewModel?) -> PointDetailsViewModel? {
        guard let pointViewModel = pointViewModel else {
            return nil
        }
        return PointDetailsViewModel(point: pointViewModel.point)
    }
    
    // MARK: - Search
    
    func searchPoints(with string: String) {
        self.searchString = string
        let predicate = Point.searchPredicate(string)
        let points = Point.searchPointsWith(predicate: predicate)
        let pointModels = points.map({
            PointViewModel(point: $0)
        })
        
        if self.searchString != string {
            return
        }
        
        self._foundedPoints.value = pointModels
        
    }
}
