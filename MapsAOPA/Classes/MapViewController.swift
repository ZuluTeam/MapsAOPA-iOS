//
//  MapViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/14/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import MapKit
import INTULocationManager
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView : MKMapView?
    @IBOutlet weak var detailsView : UIView?
    
    @IBOutlet var changingConstraints : [DependentLayoutConstraint]!
    
    private var fetchRequest = NSFetchRequest(entityName: "Point")
    private var fetchedResultsController : NSFetchedResultsController
    
    private var selectedAnnotation : PointAnnotation? {
        didSet {
            self.showPointInfo(selectedAnnotation?.point, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "index", ascending: true) ]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: Database.sharedDatabase.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userTrackingItem = MKUserTrackingBarButtonItem(mapView: self.mapView)
        let mapStyleItem = MultipleStatesBarButtonItem(states: ["Sch", "Hyb", "Sat" ], currentState: 0) { [ weak self] (state) in
            switch state
            {
            case 0: self?.mapView?.mapType = MKMapType.Standard
            case 1: self?.mapView?.mapType = MKMapType.Hybrid
            case 2: self?.mapView?.mapType = MKMapType.Satellite
            default: break
            }
        }
        
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let airportsFilterItem = MultipleStatesBarButtonItem(states: ["A:None", "A:Active", "A:All"],
                                                             currentState: Config.pointsFilter.airportsState.rawValue,
                                                             action: { [weak self] (state) -> () in
                                                                var filter = Config.pointsFilter
                                                                filter.airportsState = PointsFilterState(rawValue: state) ?? .Active
                                                                Config.pointsFilter = filter
                                                                self?.reloadPoints()
        })
        let heliportsFilterItem = MultipleStatesBarButtonItem(states: ["H:None", "H:Active", "H:All"],
                                                              currentState: Config.pointsFilter.heliportsState.rawValue,
                                                              action:  { [weak self] (state) -> () in
                                                                var filter = Config.pointsFilter
                                                                filter.heliportsState = PointsFilterState(rawValue: state) ?? .None
                                                                Config.pointsFilter = filter
                                                                self?.reloadPoints()
        })
        self.toolbarItems = [userTrackingItem, mapStyleItem, spacerItem, airportsFilterItem, heliportsFilterItem]
        
        self.mapView?.setRegion(Config.mapRegion(withDefaultCoordinate: Config.defaultCoordinate), animated: false)
        
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.Block, timeout: NSTimeInterval(CGFloat.max), delayUntilAuthorized: false, block: { [weak self] (location, accuracy, status) in
            var mapLocation : CLLocationCoordinate2D = Config.defaultCoordinate
            if status == .Success
            {
                self?.mapView?.showsUserLocation = true
                mapLocation = location.coordinate
            }
            let mapRegion = Config.mapRegion(withDefaultCoordinate: mapLocation)
            self?.mapView?.setRegion(mapRegion, animated: true)
        })
        
        self.showPointInfo(self.selectedAnnotation?.point, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Private
    
    private func reloadPoints()
    {
        if let mapView = self.mapView
        {
            self.reloadPoints(inRegion: mapView.region)
        }
    }
    
    private func reloadPoints(inRegion region: MKCoordinateRegion)
    {
        self.fetchRequest.predicate = Database.pointsPredicate(forRegion: region, withFilter: Config.pointsFilter)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            do {
                try self.fetchedResultsController.performFetch()
                dispatch_async(dispatch_get_main_queue(), { 
                    self.refreshPoints(self.fetchedResultsController.fetchedObjects as? [Point] ?? [])
                })
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        })
    }
    
    private func refreshPoints( points : [Point])
    {
        var points = points
        let annotationsToRemove = self.mapView?.annotations.filter({ annotation in
            if let point = (annotation as? PointAnnotation)?.point
            {
                if let index = points.indexOf(point)
                {
                    points.removeAtIndex(index)
                    return false
                }
            }
            return true
        })
        
        if let annotations = annotationsToRemove
        {
            self.mapView?.removeAnnotations(annotations)
        }
        for point in points
        {
            if let annotation = PointAnnotation(point: point)
            {
                self.mapView?.addAnnotation(annotation)
            }
        }
    }
    
    private func showPointInfo(point: Point?, animated: Bool)
    {
        if let point = point
        {
            self.detailsView?.hidden = false
        }
        UIView.animateWithDuration(0.25 * NSTimeInterval(animated), animations: {
            for constraint in self.changingConstraints
            {
                constraint.constant = -(CGFloat(nil == point) * (constraint.valueConstraint?.constant ?? 0.0))
            }
            self.view.layoutIfNeeded()
        }) { completed in self.detailsView?.hidden = nil == point }
    }

    // MARK: - MKMapViewDelegate
 
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Config.saveRegion(mapView.region)
        self.reloadPoints(inRegion: mapView.region)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PointAnnotation
        {
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("PointAnnotation") as? PointAnnotationView
            if nil == view
            {
                view = PointAnnotationView.view(withAnnotation: annotation)
            }
            view?.annotation = annotation
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation as? PointAnnotation
        {
            self.selectedAnnotation = annotation
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        self.selectedAnnotation = nil
    }
}

