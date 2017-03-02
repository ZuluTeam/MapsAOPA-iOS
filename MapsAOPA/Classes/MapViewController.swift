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


class MapViewController: UIViewController, MKMapViewDelegate, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var detailsView : PointDetailsView!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!
    
    @IBOutlet var detailsConstraints : [NSLayoutConstraint]!
    
    fileprivate lazy var viewModel = MapViewModel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingIndicator.reactive.isAnimating <~ self.viewModel.isLoading
        let _ = self.viewModel.errorMessage.signal.on(value: { self.displayError(message: $0) })
        
        let userTrackingItem = MKUserTrackingBarButtonItem(mapView: self.mapView)
        let mapStyleItem = MultipleStatesBarButtonItem(states: ["Sch" as AnyObject, "Hyb" as AnyObject, "Sat" as AnyObject ], currentState: 0) { [ weak self] (state) in
            switch state
            {
            case 0: self?.mapView.mapType = MKMapType.standard
            case 1: self?.mapView.mapType = MKMapType.hybrid
            case 2: self?.mapView.mapType = MKMapType.satellite
            default: break
            }
        }
        
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let airportsFilterItem = MultipleStatesBarButtonItem(states: ["\(AppIcons.MakiAirfield.rawValue) None" as AnyObject,
                                                                      "\(AppIcons.MakiAirfield.rawValue) Active" as AnyObject,
                                                                      "\(AppIcons.MakiAirfield.rawValue) All" as AnyObject],
                                                             currentState: Settings.pointsFilter.airportsState.rawValue,
                                                             action: { [weak self] (state) -> () in
                                                                if var filter = self?.viewModel.pointsFilter {
                                                                    filter.airportsState = PointsFilterState(rawValue: state) ?? .active
                                                                    self?.viewModel.pointsFilter = filter
                                                                }
        })
        airportsFilterItem.setTitleTextAttributes([ NSFontAttributeName: UIFont.makiFont(ofSize: 20) ], for: .normal)
        let heliportsFilterItem = MultipleStatesBarButtonItem(states: ["\(AppIcons.MakiHeliport.rawValue) None" as AnyObject,
                                                                       "\(AppIcons.MakiHeliport.rawValue) Active" as AnyObject,
                                                                       "\(AppIcons.MakiHeliport.rawValue) All" as AnyObject],
                                                              currentState: Settings.pointsFilter.heliportsState.rawValue,
                                                              action:  { [weak self] (state) -> () in
                                                                if var filter = self?.viewModel.pointsFilter {
                                                                    filter.heliportsState = PointsFilterState(rawValue: state) ?? .active
                                                                    self?.viewModel.pointsFilter = filter
                                                                }
        })
        heliportsFilterItem.setTitleTextAttributes([ NSFontAttributeName: UIFont.makiFont(ofSize: 20) ], for: .normal)
        
        self.toolbarItems = [userTrackingItem, mapStyleItem, spacerItem, airportsFilterItem, heliportsFilterItem]
        
        self.mapView.setRegion(Settings.mapRegion(withDefaultCoordinate: Settings.defaultCoordinate), animated: false)
        
        INTULocationManager.sharedInstance().requestLocation(withDesiredAccuracy: .block, timeout: TimeInterval(CGFloat.greatestFiniteMagnitude), delayUntilAuthorized: false, block: { [weak self] (location, accuracy, status) in
            var mapLocation : CLLocationCoordinate2D = Settings.defaultCoordinate
            if status == .success {
                self?.mapView.showsUserLocation = true
                mapLocation = (location?.coordinate)!
            }
            let mapRegion = Settings.mapRegion(withDefaultCoordinate: mapLocation)
            self?.mapView.setRegion(mapRegion, animated: true)
        })
        
        self.viewModel.mapPoints.producer.startWithValues { [weak self] points in
            self?.refreshPoints(points)
        }
        
        self.viewModel.selectedPoint.producer.skip(first: 1).startWithValues { [weak self] point in
            self?.showPointInfo(self?.viewModel.pointDetailsViewModel(from: point), animated: true)
        }
        
        self.viewModel.loadAirfields()
        
        let _ = self.detailsView.websiteButton?.reactive.controlEvents(.touchUpInside).observeValues({ [weak self] button in
            self?.openURL(self?.detailsView.pointDetailsViewModel?.website)
        })
        
        let _ = self.detailsView.emailButton?.reactive.controlEvents(.touchUpInside).observeValues({ [weak self] button in
            self?.sendEmail(self?.detailsView.pointDetailsViewModel?.email)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.showPointInfo(self.viewModel.pointDetailsViewModel(from: self.viewModel.selectedPoint.value), animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? DetailsTableViewController {
            switch segue.identifier ?? "" {
            case Segue.ContactsSegue.rawValue:
                destinationViewController.viewModel = DetailsViewModel(contacts: self.detailsView.pointDetailsViewModel?.contacts ?? [])
            case Segue.FrequenciesSegue.rawValue:
                destinationViewController.viewModel = DetailsViewModel(frequencies: self.detailsView.pointDetailsViewModel?.frequencies ?? [])
            default: break
            }
            destinationViewController.popoverPresentationController?.delegate = self
            destinationViewController.title = self.detailsView.pointDetailsViewModel?.title
            let height : CGFloat = 300.0
            destinationViewController.preferredContentSize = CGSize(width: self.view.width, height: height)
        }
    }
    
    // MARK: - Private
    
    fileprivate func openURL(_ url: String?) {
        if var website = url {
            if(!website.contains("://")) {
                website = "http://" + website
            }
            if let url = URL(string: website), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    fileprivate func refreshPoints(_ points : [PointViewModel]) {
        var points = points
        let annotationsToRemove = self.mapView.annotations.filter({ annotation in
            if let pointViewModel = (annotation as? PointAnnotation)?.pointViewModel {
                if let index = points.index(of: pointViewModel) {
                    points.remove(at: index)
                    return false
                }
            }
            return true
        })
        
        self.mapView.removeAnnotations(annotationsToRemove)
        
        for point in points {
            self.mapView.addAnnotation(PointAnnotation(pointViewModel: point))
        }
    }
    
    fileprivate func showPointInfo(_ pointDetails: PointDetailsViewModel?, animated: Bool)
    {
        self.detailsView.pointDetailsViewModel = pointDetails
        let constraints = self.view.constraints
        for constraint in constraints {
            if constraint.identifier == "DetailsBottom" {
                constraint.constant = -(CGFloat(nil == pointDetails) * self.detailsView.height)
            } else if constraint.identifier == "DetailsLeft" {
                constraint.constant = -(CGFloat(nil == pointDetails) * self.detailsView.width)
            }
        }
        UIView.animate(withDuration: 0.25 * TimeInterval(animated)) {
            self.detailsView.layoutIfNeeded()
        }
        
        if let pointDetails = pointDetails {
            self.mapView.add(RunwaysOverlay(pointDetailsViewModel: pointDetails))
        } else {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }

    // MARK: - MKMapViewDelegate
 
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.viewModel.mapRegion = mapView.region
        for overlay in mapView.overlays {
            mapView.renderer(for: overlay)?.setNeedsDisplayIn(mapView.visibleMapRect)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PointAnnotation {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "PointAnnotation") as? PointAnnotationView
            if nil == view {
                view = PointAnnotationView(annotation: annotation, reuseIdentifier: "PointAnnotation")
            }
            view?.annotation = annotation
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pointViewModel = (view.annotation as? PointAnnotation)?.pointViewModel {
            self.viewModel.selectedPoint.value = pointViewModel
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.viewModel.selectedPoint.value = nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return RunwaysOverlayRenderer(overlay: overlay)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func sendEmail(_ email: String?) {
        guard let email = email else {
            return
        }
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
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
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

