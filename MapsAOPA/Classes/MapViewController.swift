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
import ReactiveSwift
import ReactiveCocoa


class MapViewController: UIViewController, MKMapViewDelegate, PointDetailsDelegate, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var mapView : MKMapView?
    @IBOutlet weak var detailsView : PointDetailsView?
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!
    
    fileprivate lazy var viewModel = MapViewModel()
    
    fileprivate var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
    fileprivate var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>
    
    fileprivate var animationsQueue = OperationQueue.main
    
    required init?(coder aDecoder: NSCoder) {
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "index", ascending: true) ]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: Database.sharedDatabase.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init(coder: aDecoder)
        self.loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailsView?.delegate = self
        
        self.loadingIndicator.reactive.isAnimating <~ self.viewModel.isLoading
        let _ = self.viewModel.errorMessage.signal.on(value: { self.displayError(message: $0) })
        
        let userTrackingItem = MKUserTrackingBarButtonItem(mapView: self.mapView)
        let mapStyleItem = MultipleStatesBarButtonItem(states: ["Sch" as AnyObject, "Hyb" as AnyObject, "Sat" as AnyObject ], currentState: 0) { [ weak self] (state) in
            switch state
            {
            case 0: self?.mapView?.mapType = MKMapType.standard
            case 1: self?.mapView?.mapType = MKMapType.hybrid
            case 2: self?.mapView?.mapType = MKMapType.satellite
            default: break
            }
        }
        
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let airportsFilterItem = MultipleStatesBarButtonItem(states: ["A:None" as AnyObject, "A:Active" as AnyObject, "A:All" as AnyObject],
                                                             currentState: Settings.pointsFilter.airportsState.rawValue,
                                                             action: { [weak self] (state) -> () in
                                                                var filter = Settings.pointsFilter
                                                                filter.airportsState = PointsFilterState(rawValue: state) ?? .active
                                                                Settings.pointsFilter = filter
                                                                self?.reloadPoints()
        })
        let heliportsFilterItem = MultipleStatesBarButtonItem(states: ["H:None" as AnyObject, "H:Active" as AnyObject, "H:All" as AnyObject],
                                                              currentState: Settings.pointsFilter.heliportsState.rawValue,
                                                              action:  { [weak self] (state) -> () in
                                                                var filter = Settings.pointsFilter
                                                                filter.heliportsState = (PointsFilterState(rawValue: state) ?? .none)!
                                                                Settings.pointsFilter = filter
                                                                self?.reloadPoints()
        })
        self.toolbarItems = [userTrackingItem, mapStyleItem, spacerItem, airportsFilterItem, heliportsFilterItem]
        
        self.mapView?.setRegion(Settings.mapRegion(withDefaultCoordinate: Settings.defaultCoordinate), animated: false)
        
        INTULocationManager.sharedInstance().requestLocation(withDesiredAccuracy: .block, timeout: TimeInterval(CGFloat.greatestFiniteMagnitude), delayUntilAuthorized: false, block: { [weak self] (location, accuracy, status) in
            var mapLocation : CLLocationCoordinate2D = Settings.defaultCoordinate
            if status == .success
            {
                self?.mapView?.showsUserLocation = true
                mapLocation = (location?.coordinate)!
            }
            let mapRegion = Settings.mapRegion(withDefaultCoordinate: mapLocation)
            self?.mapView?.setRegion(mapRegion, animated: true)
        })
        
        self.showPointInfo((mapView?.selectedAnnotations.first as? PointAnnotation)?.point, animated: false)
        
        self.viewModel.loadAirfields(force: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? DetailsTableViewController
        {
            switch segue.identifier ?? "" {
            case Segue.ContactsSegue.rawValue:
                    destinationViewController.objects = self.detailsView?.point?.details?.contacts as? [[String:AnyObject]]
                    destinationViewController.cellReuseIdentifier = DetailsReuseIdentifier.ContactsCell
                    destinationViewController.popoverPresentationController?.delegate = self
            case Segue.FrequenciesSegue.rawValue:
                    destinationViewController.objects = self.detailsView?.point?.details?.frequencies as? [[String:AnyObject]]
                    destinationViewController.cellReuseIdentifier = DetailsReuseIdentifier.FrequenciesCell
                    destinationViewController.popoverPresentationController?.delegate = self
            default: break
            }
            destinationViewController.title = self.detailsView?.point?.titleRu
            let height : CGFloat = 200.0 /*destinationViewController.objects?.reduce(28.0, { (result, object) -> CGFloat in
                return result + ((SwiftClassFromString(destinationViewController.cellReuseIdentifier.cellClass) as? DetailsTableViewCell.Type)?.cellHeight(forObject: object) ?? 0.0)
            }) ?? self.view.height*/
            destinationViewController.preferredContentSize = CGSize(width: self.view.width, height: height)
        }
    }
    
    // MARK: - Private
    
    fileprivate func loadData()
    {
//        viewModel.loadSignal().on(
//            started: {
//                [weak self] in self?.loading = true
//            },
//            failed: { [weak self] error in
//                self?.loading = false
//                print(error)
//                if error.domain == AOPAError.domain
//                {
//                    if let errorCode = AOPAError(rawValue: error.code)
//                    {
//                        switch errorCode
//                        {
//                        case .apiKeyRequired:
//                            let alertController = UIAlertController(title: "title_api_key_required".localized(), message: "message_api_key_required".localized(), preferredStyle: .alert)
//                            let saveAction = UIAlertAction(title: "button_save".localized(), style: UIAlertActionStyle.default, handler: { (action) in
//                                if let textField = alertController.textFields?.first
//                                {
//                                    let text = textField.text ?? ""
//                                    DataLoader.apiKey = text
//                                    self?.loadData()
//                                }
//                            })
//                            saveAction.isEnabled = false
//                            alertController.addAction(saveAction)
//                            alertController.addAction(UIAlertAction(title: "button_cancel".localized(), style: .cancel, handler: { (action) in
//                                // TODO: show reload button
//                                alertController.dismiss(animated: true, completion: nil)
//                            }))
////                            alertController.addTextFieldWithConfigurationHandler({ [weak saveAction] (textField : UITextField) in
////                                textField.rac_textSignal().toSignalProducer().startWithNext({ (text) in
////                                    saveAction?.enabled = ((text as? String)?.length ?? 0) > 0
////                                })
////                            })
//                            self?.present(alertController, animated: true, completion: nil)
//                        default: break
//                        }
//                    }
//                }
//                else
//                {
//                    let alert = UIAlertView(title: "title_error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "button_ok".localized())
//                    alert.show()
//                }
//            },
//            completed: {
//                [weak self] in self?.reloadPoints(); self?.loading = false
//        }).start()
    }
    
    fileprivate func reloadPoints()
    {
        if let mapView = self.mapView
        {
            self.reloadPoints(inRegion: mapView.region)
        }
    }
    
    fileprivate func reloadPoints(inRegion region: MKCoordinateRegion)
    {
        self.fetchRequest.predicate = Database.pointsPredicate(forRegion: region, withFilter: Settings.pointsFilter)
        
        DispatchQueue.global().async(execute: {
            do {
                try self.fetchedResultsController.performFetch()
                DispatchQueue.main.async(execute: { 
                    self.refreshPoints(self.fetchedResultsController.fetchedObjects as? [Point] ?? [])
                })
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        })
    }
    
    fileprivate func refreshPoints(_ points : [Point])
    {
        var points = points
        let annotationsToRemove = self.mapView?.annotations.filter({ annotation in
            if let point = (annotation as? PointAnnotation)?.point
            {
                if let index = points.index(of: point)
                {
                    points.remove(at: index)
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
    
    fileprivate func showPointInfo(_ point: Point?, animated: Bool)
    {
        if let point = point
        {
            self.detailsView?.isHidden = false
            self.detailsView?.point = point
        }
        else
        {
            self.reloadPoints()
        }
        self.animationsQueue.cancelAllOperations()
        let operation = BlockOperation { 
//            UIView.animate(withDuration: 0.25 * TimeInterval(animated), animations: {
//                for constraint in self.changingConstraints
//                {
//                    constraint.constant = -(CGFloat(nil == point) * (constraint.valueConstraint?.constant ?? 0.0))
//                }
                self.view.layoutIfNeeded()
//            }, completion: { completed in self.detailsView?.isHidden = self.mapView?.selectedAnnotations.count <= 0 }) 
        }
        
        self.animationsQueue.addOperation(operation)
    }

    // MARK: - MKMapViewDelegate
 
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Settings.saveRegion(mapView.region)
        self.reloadPoints(inRegion: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PointAnnotation
        {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "PointAnnotation") as? PointAnnotationView
            if nil == view
            {
//                view = PointAnnotationView(annotation: annotation)
            }
            view?.annotation = annotation
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.showPointInfo((mapView.selectedAnnotations.first as? PointAnnotation)?.point, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.showPointInfo((mapView.selectedAnnotations.first as? PointAnnotation)?.point, animated: true)
    }
    
    // MARK: - PointDetailsDelegate
    
    func sendEmail(_ email: String) {
        if MFMailComposeViewController.canSendMail()
        {
            let controller = MFMailComposeViewController()
            controller.setToRecipients([ email ])
            controller.mailComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else
        {
            if let url = URL(string: "mailto:?to=\(email)"), UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Error
    
    private func displayError(message: String?) {
        if let message = message {
            let alert = UIAlertController(title: "Error_Title".localized(), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Button_Ok".localized(), style: .destructive))
            self.present(alert, animated: true)
        }
    }
}

