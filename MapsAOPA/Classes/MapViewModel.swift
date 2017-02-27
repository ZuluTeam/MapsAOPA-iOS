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
import CoreData

class MapViewModel
{
    var isLoading : Property<Bool> { return Property(_loading) }
    var errorMessage : Property<String?> { return Property(_errorMessage) }
    
    var mapRegion = Settings.mapRegion(withDefaultCoordinate: Settings.defaultCoordinate) {
        didSet {
            self.updateRegion(mapRegion, withFilter: self.pointsFilter)
        }
    }
    var mapPoints : Property<[PointViewModel]> { return Property(_mapPoints) }
    
    var pointsFilter = Settings.pointsFilter {
        didSet {
            Settings.pointsFilter = pointsFilter
            self.updateRegion(self.mapRegion, withFilter: pointsFilter)
        }
    }
    
    var selectedPoint = MutableProperty<PointViewModel?>(nil)
    
    fileprivate let _loading = MutableProperty<Bool>(false)
    fileprivate let _errorMessage = MutableProperty<String?>(nil)
    
    fileprivate let _mapPoints = MutableProperty<[PointViewModel]>([])
    
    fileprivate let network : Network
    fileprivate let loader : AOPALoader
    
    fileprivate var xmlParser : ArrayXMLParser?
    
    fileprivate var mainContext : NSManagedObjectContext {
        return Database.sharedDatabase.managedObjectContext
    }
    fileprivate var fetchRequest = NSFetchRequest<Point>(entityName: "Point")
    
    init() {
        self.network = Network()
        self.loader = AOPALoader(network: network)
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "index", ascending: true) ]
        fetchRequest.fetchBatchSize = 100
        fetchRequest.returnsObjectsAsFaults = false
    }
    
    func loadAirfields(force: Bool = false) {
#if DEBUG
        let force = true
#endif
        let date = Date()
        if !force && date.timeIntervalSince(Settings.lastUpdate) < Settings.reloadDataTimeInterval {
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
                Settings.lastUpdate = Date()
                Database.sharedDatabase.saveContext(Database.sharedDatabase.backgroundManagedObjectContext)
                if let selfInstance = self {
                    selfInstance.updateRegion(selfInstance.mapRegion, withFilter: selfInstance.pointsFilter)
                }
                print("Complete savings")
            },
              value: { value in
                if let pointDict = value as? [String:AnyObject] {
                
                    Database.sharedDatabase.backgroundManagedObjectContext.performAndWait {
                        let _ = Point.point(fromDictionary: pointDict, inContext: Database.sharedDatabase.backgroundManagedObjectContext)
                    
                        Database.sharedDatabase.backgroundManagedObjectContext.delayedSaveOrRollback(completion: { (saved) in
                            if saved {
                                Database.sharedDatabase.backgroundManagedObjectContext.reset()
                            }
                        })
                    }
                }
        }).start()
    }
    
    private func updateRegion(_ region: MKCoordinateRegion, withFilter filter: PointsFilter) {
        Settings.saveRegion(region)
        self.fetchRequest.predicate = Database.pointsPredicate(forRegion: region, withFilter: filter)
        DispatchQueue.global().async(execute: {
            do {
                let points = try self.mainContext.fetch(self.fetchRequest)
                var pointModels = points.map({
                    PointViewModel(point: $0)
                })
                if let selectedPoint = self.selectedPoint.value {
                    pointModels.append(selectedPoint)
                }
                
                DispatchQueue.main.async(execute: {
                    self._mapPoints.value = pointModels
                })
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        })
    }
    
    func pointDetailsViewModel(from pointViewModel: PointViewModel?) -> PointDetailsViewModel? {
        guard let pointViewModel = pointViewModel else {
            return nil
        }
        return PointDetailsViewModel(point: pointViewModel.point)
    }
}
