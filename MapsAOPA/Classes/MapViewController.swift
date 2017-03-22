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
import SwiftyTimer

protocol MapViewControllerDelegate : NSObjectProtocol {
    var statusBarStyle : UIStatusBarStyle { get set }
    func showMenu()
}


class MapViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var mapView : MKMapView!
    @IBOutlet var detailsView : PointDetailsView!
    @IBOutlet var loadingIndicator : UIActivityIndicatorView!
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var searchBackgroundView : UIView!
    @IBOutlet var searchTableContainer : UIView!
    @IBOutlet var searchTableView : UITableView!
    
    fileprivate static let zoomToPointSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    
    var viewModel: MapViewModel!
    
    weak var delegate : MapViewControllerDelegate?
    
    fileprivate var pointDetailsViewController : PointDetailsTableViewController?
    
    fileprivate static let zoomPercent: CLLocationDegrees = 0.5
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate var keyboardObserver : KeyboardObserver?
    fileprivate var searchTimer : Timer?
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if self.mapView?.mapType != MKMapType.standard {
                return .lightContent
            }
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Settings.current.mapType.producer.startWithValues { [weak self] mapType in
            self?.mapView.mapType = mapType
            self?.delegate?.statusBarStyle = self?.preferredStatusBarStyle ?? .default
        }
        
        self.searchBar.resignFirstResponder()
        self.setSearchHidden(true, animated: false)
        
        self.loadingIndicator.reactive.isAnimating <~ self.viewModel.isLoading
        let _ = self.viewModel.errorMessage.signal.on(value: { [weak self] message in
            self?.displayError(message: message)
        })
        
        let handler = InsetKeyboardHandler()
        handler.scrollView = self.searchTableView
        keyboardObserver = KeyboardObserver(handler: handler)
        keyboardObserver?.activate()
        
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
        
        self.viewModel.foundedPoints.producer.startWithValues({ [weak self] points in
            self?.searchTableView.reloadData()
            self?.searchTableView.setContentOffset(.zero, animated: true)
            if points.count > 0 {
                self?.searchTableView.separatorStyle = .singleLine
            } else {
                self?.searchTableView.separatorStyle = .none
            }
        })
        
        self.viewModel.selectedPoint.producer.skip(first: 1).startWithValues { [weak self] point in
            self?.showPointInfo(self?.viewModel.pointDetailsViewModel(from: point), animated: true)
        }
        
        self.viewModel.loadAirfields()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if nil == self.viewModel.selectedPoint.value || self.detailsView.pointDetailsViewModel?.index != self.viewModel.selectedPoint.value?.index {
            self.showPointInfo(self.viewModel.pointDetailsViewModel(from: self.viewModel.selectedPoint.value), animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? DetailsTableViewController {
            switch segue.identifier ?? "" {
            case Segue.Contacts.rawValue:
                destinationViewController.viewModel = DetailsViewModel(contacts: self.detailsView.pointDetailsViewModel?.contacts ?? [])
            case Segue.Frequencies.rawValue:
                destinationViewController.viewModel = DetailsViewModel(frequencies: self.detailsView.pointDetailsViewModel?.frequencies ?? [])
            default: break
            }
            destinationViewController.popoverPresentationController?.delegate = self
            destinationViewController.title = self.detailsView.pointDetailsViewModel?.title
            let height : CGFloat = 300.0
            destinationViewController.preferredContentSize = CGSize(width: self.view.width, height: height)
        }
        if segue.identifier == Segue.PointDetails.rawValue {
            self.pointDetailsViewController = segue.destination as? PointDetailsTableViewController
        }
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
            if point == self.viewModel.selectedPoint.value {
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    fileprivate func showPointInfo(_ pointDetails: PointDetailsViewModel?, animated: Bool)
    {
        self.detailsView.pointDetailsViewModel = pointDetails
        self.pointDetailsViewController?.pointDetailsViewModel = pointDetails
        let constraints = self.view.constraints
//        self.detailsView.isHidden = false
        for constraint in constraints {
            if constraint.identifier == "DetailsBottom" {
                constraint.constant = -(CGFloat(nil == pointDetails) * self.detailsView.height)
            } else if constraint.identifier == "DetailsLeft" {
                constraint.constant = -(CGFloat(nil == pointDetails) * self.detailsView.width)
            }
        }
        UIView.animate(withDuration: 0.25 * TimeInterval(animated), animations: {
            self.detailsView.layoutIfNeeded()
        }) { _ in
//            self.detailsView.isHidden = nil == pointDetails
        }
        
        if let pointDetails = pointDetails {
            self.mapView.add(RunwaysOverlay(pointDetailsViewModel: pointDetails))
        } else {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }
    
    fileprivate func zoom(to point: PointViewModel) {
        let region = MKCoordinateRegion(center: point.location,
                                        span: MapViewController.zoomToPointSpan)
        self.mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Gesture Recognizer Delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view is UITableViewCell || (view != self.searchTableView && view.isDescendant(of: self.searchTableView)) {
            return false
        }
        return true
        
    }
    
    // MARK: - Actions 
    
    @IBAction func tapBackgroundAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func menuAction(_ sender: AnyObject?) {
        self.delegate?.showMenu()
    }
    
    @IBAction func zoomInAction(_ sender: AnyObject?) {
        if let selectedPoint = self.viewModel.selectedPoint.value {
            self.zoom(to: selectedPoint)
        }
    }
    
    @IBAction func websiteAction(_ sender: AnyObject?) {
        self.open(url: self.detailsView.pointDetailsViewModel?.website)
    }
    
    @IBAction func mailAction(_ sender: AnyObject?) {
        self.mail(to: self.detailsView.pointDetailsViewModel?.email)
    }

    @IBAction func zoomInButtonPress(_ sender: UIButton) {
        zoomInMap()
    }
    
    @IBAction func zoomOutButtonPress(_ sender: UIButton) {
        zoomOutMap()
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
    
    
    // MARK: Zoom Buttons Action
    
    func zoomInMap() {
        var region = mapView.region
        var span = MKCoordinateSpan()
        span.latitudeDelta = region.span.latitudeDelta * (1.0 - MapViewController.zoomPercent)
        span.longitudeDelta = region.span.longitudeDelta * (1.0 - MapViewController.zoomPercent)
        region.span = span
        mapView.setRegion(region, animated: true);
    }
    
    func zoomOutMap() {
        var region = mapView.region
        var span = MKCoordinateSpan()
        span.latitudeDelta = region.span.latitudeDelta * (1.0 + MapViewController.zoomPercent)
        span.longitudeDelta = region.span.longitudeDelta * (1.0 + MapViewController.zoomPercent)
        region.span = span
        mapView.setRegion(region, animated: true);
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
    
    // MARK: - Search Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.foundedPoints.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapSearchCell", for: indexPath)
        let pointModel = self.viewModel.foundedPoints.value[indexPath.row]
        cell.textLabel?.text = pointModel.title
        cell.detailTextLabel?.text = pointModel.region
        return cell
    }
    
    // MARK: - Search Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pointModel = self.viewModel.foundedPoints.value[indexPath.row]
        self.viewModel.selectedPoint.value = pointModel
        self.zoom(to: pointModel)
        for annotation in self.mapView.annotations {
            if let annotation = annotation as? PointAnnotation, annotation.pointViewModel == pointModel {
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
        self.cancelSearching()
    }
    
    // MARK: - Search Bar Delegate
    
    fileprivate func cancelSearching() {
        self.searchBar.text = nil
        self.viewModel.searchPoints(with: "")
        self.searchBar.resignFirstResponder()
    }
    
    fileprivate func setSearchHidden(_ hidden : Bool, animated: Bool) {
        let startAlpha = CGFloat(hidden)
        let backgroundColorAlpha = 0.25 * CGFloat(!hidden)
        self.searchTableContainer.alpha = startAlpha
        self.searchTableContainer.isHidden = false
        
        UIView.animate(withDuration: 0.25 * TimeInterval(animated), animations: { 
            self.searchBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(backgroundColorAlpha)
            self.searchTableContainer.alpha = 1.0 - startAlpha
            self.searchBar.showsCancelButton = !hidden
        }) { _ in
            self.searchTableContainer.isHidden = hidden
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.setSearchHidden(false, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.setSearchHidden(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelSearching()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTimer?.invalidate()
        self.searchTimer = Timer.after(100.ms) { [weak self] in
            self?.viewModel.searchPoints(with: searchText)
        }
    }
}

