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
    var mapRegion = Settings.current.mapRegion(withDefaultCoordinate: Settings.defaultCoordinate) {
        didSet {
            self.updateRegion(mapRegion, withFilter: self.pointsFilter)
        }
    }
    var mapPoints : Property<[PointViewModel]> { return Property(_mapPoints) }
    var foundedPoints : Property<[PointViewModel]> { return Property(_foundedPoints) }
    
    var selectedPoint = MutableProperty<(point: PointViewModel, zoomIn: Bool)?>(nil)
    
    fileprivate let _mapPoints = MutableProperty<[PointViewModel]>([])
    fileprivate let _foundedPoints = MutableProperty<[PointViewModel]>([])
    
    fileprivate var backgroundContext : NSManagedObjectContext {
        return Database.sharedDatabase.backgroundManagedObjectContext
    }
    
    fileprivate var fetchRequest = NSFetchRequest<Point>(entityName: Point.entityName)
    fileprivate var searchFetchRequest = NSFetchRequest<Point>(entityName: Point.entityName)
    fileprivate var searchString : String?
    
    fileprivate var pointsFilter : PointsFilter = Settings.current.pointsFilter.value
    
    init() {
        
        Settings.current.pointsFilter.producer.startWithValues { [weak self] filter in
            if let selfInstance = self {
                selfInstance.pointsFilter = filter
                selfInstance.updateRegion(selfInstance.mapRegion, withFilter: filter)
            }
        }
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: Point.Keys.index.rawValue, ascending: true) ]
        fetchRequest.fetchBatchSize = 100
        fetchRequest.returnsObjectsAsFaults = false
        
        searchFetchRequest.sortDescriptors = [
            NSSortDescriptor(key: Point.Keys.index.rawValue, ascending: true),
            NSSortDescriptor(key: Point.Keys.searchTitle.rawValue, ascending: true),
            NSSortDescriptor(key: Point.Keys.searchTitleRu.rawValue, ascending: true)
        ]
        searchFetchRequest.fetchBatchSize = 100
        searchFetchRequest.returnsObjectsAsFaults = false
    }
    
    private func updateRegion(_ region: MKCoordinateRegion, withFilter filter: PointsFilter) {
        Settings.current.saveRegion(region)
        self.fetchRequest.predicate = Database.pointsPredicate(forRegion: region, withFilter: filter)
        DispatchQueue.global().async(execute: {
            do {
                let points = try self.backgroundContext.fetch(self.fetchRequest)
                var pointModels = points.map({
                    PointViewModel(point: $0)
                })
                if let selectedPoint = self.selectedPoint.value?.point {
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
    
    // MARK: - Search
    
    func searchPoints(with string: String) {
        self.searchString = string
        self.searchFetchRequest.predicate = Point.searchPredicate(string)
        DispatchQueue.global().async(execute: {
            do {
                let points = try self.backgroundContext.fetch(self.searchFetchRequest)
                let pointModels = points.map({
                    PointViewModel(point: $0)
                })
                
                if self.searchString != string {
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    self._foundedPoints.value = pointModels
                })
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        })
    }
}
