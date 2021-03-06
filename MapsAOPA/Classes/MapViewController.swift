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
import Sugar


class MapViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet var mapView : MKMapView!
    @IBOutlet var detailsView : PointDetailsView!
    @IBOutlet var loadingIndicator : UIActivityIndicatorView!
    @IBOutlet var centerUserLocationButton : UIButton!
    
    fileprivate static let zoomToPointSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    
    var loadingViewModel : LoadingViewModel!
    var viewModel: MapViewModel!
    
    fileprivate var pointDetails = [String:PointDetailsView]()
    
    fileprivate static let zoomPercent: CLLocationDegrees = 0.5
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Settings.current.mapType.producer.startWithValues { [weak self] mapType in
            self?.mapView.mapType = mapType
        }
        
        let _ = self.loadingViewModel.isLoading.producer.startWithValues { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
        }
        
        let _ = self.loadingViewModel.errorMessage.signal.on(value: { [weak self] message in
            self?.displayError(message: message)
        })
        
        self.mapView.setRegion(Settings.current.mapRegion(withDefaultCoordinate: Settings.defaultCoordinate), animated: false)
        
        INTULocationManager.sharedInstance().requestLocation(withDesiredAccuracy: .block, timeout: TimeInterval(CGFloat.greatestFiniteMagnitude), delayUntilAuthorized: false, block: { [weak self] (location, accuracy, status) in
            var mapLocation : CLLocationCoordinate2D = Settings.defaultCoordinate
            if status == .success {
                self?.mapView.showsUserLocation = true
                mapLocation = (location?.coordinate)!
            }
            let mapRegion = Settings.current.mapRegion(withDefaultCoordinate: mapLocation)
            self?.mapView.setRegion(mapRegion, animated: true)
        })
        
        self.viewModel.mapPoints.producer.startWithValues { [weak self] points in
            self?.refreshPoints(points)
        }
        
        self.viewModel.selectedPoint.producer.startWithValues { [weak self] point in
            if let point = point, point.zoomIn {
                self?.zoom(to: point.point)
            } else {
//                self?.showPointInfo(self?.viewModel.pointDetailsViewModel(from: point?.point), animated: true)
            }
        }
        
        self.centerUserLocationButton.titleEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for constraint in self.view.constraints {
            if constraint.identifier == "details_top", let detailsView = constraint.secondItem as? UIView {
                UIView.animate(withDuration: 0.25, delay: 0.0, animations: {
                    detailsView.y = self.view.height - detailsView.height
                }, completion: { _ in
                    constraint.constant = detailsView.height
                    constraint.identifier = nil
                    self.view.setNeedsLayout()
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destinationViewController = segue.destination as? DetailsTableViewController {
//            switch segue.identifier ?? "" {
//            case Segue.Contacts.rawValue:
//                destinationViewController.viewModel = DetailsViewModel(contacts: self.pointDetailsViewController?.viewModel?.contacts ?? [])
//            case Segue.Frequencies.rawValue:
//                destinationViewController.viewModel = DetailsViewModel(frequencies: self.pointDetailsViewController?.viewModel?.frequencies ?? [])
//            default: break
//            }
//            destinationViewController.popoverPresentationController?.delegate = self
//            destinationViewController.title = self.pointDetailsViewController?.viewModel?.title
//            let height : CGFloat = 300.0
//            destinationViewController.preferredContentSize = CGSize(width: self.view.width, height: height)
//        }
//        if segue.identifier == Segue.PointDetails.rawValue {
//            self.pointDetailsViewController = segue.destination as? PointDetailsViewController
//        }
    }
    
    // MARK: - Private
    
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
            let annotation = PointAnnotation(pointViewModel: point)
            self.mapView.addAnnotation(annotation)
            if point == self.viewModel.selectedPoint.value?.point {
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    fileprivate func select(annotationView view: MKAnnotationView) {
        if let pointViewModel = (view.annotation as? PointAnnotation)?.pointViewModel {
            let index = pointViewModel.index
            if self.pointDetails[index] != nil {
                return
            }
            if let detailsViewModel = self.viewModel.pointDetailsViewModel(from: pointViewModel),
                let detailsView = PointDetailsView.view(model: detailsViewModel) {
                detailsView.translatesAutoresizingMaskIntoConstraints = false
                self.pointDetails[index] = detailsView
                self.view.addSubview(detailsView)
                self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: detailsView, attribute: .leading, multiplier: 1.0, constant: 0.0))
                self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: detailsView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
                let topConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: detailsView, attribute: .top, multiplier: 1.0, constant: 0.0)
                topConstraint.identifier = "details_top"
                self.view.addConstraint(topConstraint)
                self.view.setNeedsLayout()
            }
        }
    }
    
    fileprivate func deselect(annotationView view: MKAnnotationView) {
        if let pointViewModel = (view.annotation as? PointAnnotation)?.pointViewModel {
            let index = pointViewModel.index
            if let view = self.pointDetails[index] {
                UIView.animate(withDuration: 0.25, animations: { 
                    view.alpha = 0.0
                }, completion: { _ in
                    view.removeFromSuperview()
                })
                self.pointDetails[index] = nil
            }
        }
        /*
        if let pointDetailsViewController = self.pointDetailsViewControllers[view] {
            pointDetailsViewController.view.alpha = 1.0
            UIView.animate(withDuration: 0.25, animations: { 
                pointDetailsViewController.view.alpha = 0.0
            }, completion: { _ in
                pointDetailsViewController.view.removeFromSuperview()
                pointDetailsViewController.removeFromParentViewController()
            })
        }
        self.mapView.removeOverlays(self.mapView.overlays)*/
    }
    
    fileprivate func zoom(to point: PointViewModel) {
        let region = MKCoordinateRegion(center: point.location,
                                        span: MapViewController.zoomToPointSpan)
        self.mapView.setRegion(region, animated: true)
    }
    
    fileprivate func zoom(in isIn: Bool) {
        let k : CLLocationDegrees = isIn ? -1 : 1
        let camera = mapView.camera
        camera.altitude = camera.altitude * (1.0 + k * MapViewController.zoomPercent)
        mapView.setCamera(camera, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func zoomPointAction(_ sender: AnyObject?) {
        if let selectedPoint = self.viewModel.selectedPoint.value?.point {
            self.zoom(to: selectedPoint)
        }
    }
    
    @IBAction func websiteAction(_ sender: AnyObject?) {
//        self.open(url: self.pointDetailsViewController?.viewModel?.website)
    }
    
    @IBAction func mailAction(_ sender: AnyObject?) {
//        self.mail(to: self.pointDetailsViewController?.viewModel?.email)
    }

    @IBAction func zoomInAction(_ sender: UIButton) {
        zoom(in: true)
    }
    
    @IBAction func zoomOutAction(_ sender: UIButton) {
        zoom(in: false)
    }
    
    @IBAction func centerUserLocationAction(_ sender: UIButton) {
        var mapRegion = self.mapView.region
        let center = self.mapView.userLocation
        mapRegion.center = center.coordinate
        self.mapView.setRegion(mapRegion, animated: true)
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
        self.select(annotationView: view)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.deselect(annotationView: view)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return RunwaysOverlayRenderer(overlay: overlay)
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

