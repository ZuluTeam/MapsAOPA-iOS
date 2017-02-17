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
    
    fileprivate var xmlParser : ItemsXMLParser?
    
    fileprivate var fetchRequest = NSFetchRequest<Point>(entityName: "Point")
    fileprivate var fetchedResultsController : NSFetchedResultsController<Point>
    
    init() {
        self.network = Network()
        self.loader = AOPALoader(network: network)
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "index", ascending: true) ]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: Database.sharedDatabase.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func loadAirfields(force: Bool = false) {
        let date = Date()
        if !force && date.timeIntervalSince(Settings.lastUpdate) < Settings.reloadDataTimeInterval {
            return
        }
        _loading.value = true
        
        self.loader.loadAirfields().flatMap(.latest, transform: { [weak self] (url : URL) -> SignalProducer<Any, AOPAError> in
            self?.xmlParser = ItemsXMLParser(contentsOf: url, forItems: "point")
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
            },
              value: { value in
                if let pointDict = value as? [String:AnyObject] {
                    let _ = Point.point(fromDictionary: pointDict, inContext: Database.sharedDatabase.backgroundManagedObjectContext)
                }
        }).start()
    }
    
    private func updateRegion(_ region: MKCoordinateRegion, withFilter filter: PointsFilter) {
        Settings.saveRegion(region)
        self.fetchRequest.predicate = Database.pointsPredicate(forRegion: region, withFilter: filter)
        
        DispatchQueue.global().async(execute: {
            do {
                try self.fetchedResultsController.performFetch()
                DispatchQueue.main.async(execute: {
                    var pointModels = (self.fetchedResultsController.fetchedObjects ?? []).map{
                        PointViewModel(point: $0)
                    }
                    if let selectedPoint = self.selectedPoint.value {
                        pointModels.append(selectedPoint)
                    }
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
        let point = self.fetchedResultsController.fetchedObjects?.findFirst({ $0.index == pointViewModel.index })
        return PointDetailsViewModel(point: point)
    }
}
