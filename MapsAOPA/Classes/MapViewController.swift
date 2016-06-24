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
import MessageUI

class MapViewController: UIViewController, MKMapViewDelegate, PointDetailsDelegate, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var mapView : MKMapView?
    @IBOutlet weak var detailsView : PointDetailsView?
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView?
    
    @IBOutlet var changingConstraints : [DependentLayoutConstraint]!
    
    private lazy var viewModel = MapViewModel()
    private var loading : Bool = false {
        didSet {
            if loading
            {
                self.loadingIndicator?.startAnimating()
            }
            else
            {
                self.loadingIndicator?.stopAnimating()
            }
        }
    }
    private var fetchRequest = NSFetchRequest(entityName: "Point")
    private var fetchedResultsController : NSFetchedResultsController
    
    private var animationsQueue = NSOperationQueue.mainQueue()
    
    required init?(coder aDecoder: NSCoder) {
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "index", ascending: true) ]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: Database.sharedDatabase.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init(coder: aDecoder)
        self.loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailsView?.delegate = self
        if self.loading
        {
            self.loadingIndicator?.startAnimating()
        }
        else
        {
            self.loadingIndicator?.stopAnimating()
        }
        
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
        
        self.showPointInfo((mapView?.selectedAnnotations.first as? PointAnnotation)?.point, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case Segue.ContactsSegue.rawValue:
            if let destinationViewController = segue.destinationViewController as? DetailsTableViewController
            {
                destinationViewController.title = self.detailsView?.point?.titleRu
                destinationViewController.objects = self.detailsView?.point?.details?.contacts as? [[String:AnyObject]]
                destinationViewController.cellReuseIdentifier = DetailsReuseIdentifier.ContactsCell
                destinationViewController.popoverPresentationController?.delegate = self
                let height : CGFloat = destinationViewController.objects?.reduce(0.0, combine: { (result, object) -> CGFloat in
                    return result + ((SwiftClassFromString(DetailsReuseIdentifier.ContactsCell.cellClass) as? DetailsTableViewCell.Type)?.cellHeight(forObject: object) ?? 0.0)
                }) ?? self.view.height
                destinationViewController.preferredContentSize = CGSize(width: self.view.width, height: height)
            }
        case Segue.FrequenciesSegue.rawValue:
            if let destinationViewController = segue.destinationViewController as? DetailsTableViewController
            {
                destinationViewController.objects = self.detailsView?.point?.details?.frequencies as? [[String:AnyObject]]
                destinationViewController.cellReuseIdentifier = DetailsReuseIdentifier.FrequenciesCell
                destinationViewController.popoverPresentationController?.delegate = self
                let height : CGFloat = destinationViewController.objects?.reduce(0.0, combine: { (result, object) -> CGFloat in
                    return result + ((SwiftClassFromString(DetailsReuseIdentifier.FrequenciesCell.cellClass) as? DetailsTableViewCell.Type)?.cellHeight(forObject: object) ?? 0.0)
                }) ?? self.view.height
                destinationViewController.preferredContentSize = CGSize(width: self.view.width, height: height)
            }
        default: break
        }
    }
    
    // MARK: - Private
    
    private func loadData()
    {
        viewModel.loadSignal().on(
            started: {
                [weak self] in self?.loading = true
            },
            completed: {
                [weak self] in self?.reloadPoints(); self?.loading = false
            },
            failed: { [weak self] error in
                self?.loading = false
                print(error)
                if error.domain == Error.domain
                {
                    if let errorCode = Error(rawValue: error.code)
                    {
                        switch errorCode
                        {
                        case .ApiKeyRequired:
                            let alertController = UIAlertController(title: "title_api_key_required".localized(), message: "message_api_key_required".localized(), preferredStyle: .Alert)
                            let saveAction = UIAlertAction(title: "button_save".localized(), style: UIAlertActionStyle.Default, handler: { (action) in
                                if let textField = alertController.textFields?.first
                                {
                                    let text = textField.text ?? ""
                                    DataLoader.apiKey = text
                                    self?.loadData()
                                }
                            })
                            saveAction.enabled = false
                            alertController.addAction(saveAction)
                            alertController.addAction(UIAlertAction(title: "button_cancel".localized(), style: .Cancel, handler: { (action) in
                                // TODO: show reload button
                                alertController.dismissViewControllerAnimated(true, completion: nil)
                            }))
                            alertController.addTextFieldWithConfigurationHandler({ [weak saveAction] (textField : UITextField) in
                                textField.rac_textSignal().toSignalProducer().startWithNext({ (text) in
                                    saveAction?.enabled = ((text as? String)?.length ?? 0) > 0
                                })
                                })
                            self?.presentViewController(alertController, animated: true, completion: nil)
                        default: break
                        }
                    }
                }
                else
                {
                    let alert = UIAlertView(title: "title_error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "button_ok".localized())
                    alert.show()
                }
            }).start()
    }
    
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
    
    private func refreshPoints(points : [Point])
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
                return point.index != (mapView?.selectedAnnotations.first as? PointAnnotation)?.point.index
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
            self.detailsView?.point = point
        }
        else
        {
            self.reloadPoints()
        }
        self.animationsQueue.cancelAllOperations()
        let operation = NSBlockOperation { 
            UIView.animateWithDuration(0.25 * NSTimeInterval(animated), animations: {
                for constraint in self.changingConstraints
                {
                    constraint.constant = -(CGFloat(nil == point) * (constraint.valueConstraint?.constant ?? 0.0))
                }
                self.view.layoutIfNeeded()
            }) { completed in self.detailsView?.hidden = self.mapView?.selectedAnnotations.count <= 0 }
        }
        
        self.animationsQueue.addOperation(operation)
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
                view = PointAnnotationView(annotation: annotation)
            }
            view?.annotation = annotation
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.showPointInfo((mapView.selectedAnnotations.first as? PointAnnotation)?.point, animated: true)
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        self.showPointInfo((mapView.selectedAnnotations.first as? PointAnnotation)?.point, animated: true)
    }
    
    // MARK: - PointDetailsDelegate
    
    func sendEmail(email: String) {
        if MFMailComposeViewController.canSendMail()
        {
            let controller = MFMailComposeViewController()
            controller.setToRecipients([ email ])
            controller.mailComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
        else
        {
            if let url = NSURL(string: "mailto:?to=\(email)") where UIApplication.sharedApplication().canOpenURL(url)
            {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}

