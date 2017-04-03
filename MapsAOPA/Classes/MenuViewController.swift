//
//  MenuViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/20/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import MapKit
import ReactiveSwift

class MenuViewController: UIViewController {
    
    @IBOutlet var mapTypeControl : UISegmentedControl!
    @IBOutlet var distanceUnitsControl : UISegmentedControl!
    @IBOutlet var pressureControl : UISegmentedControl!
    @IBOutlet var reloadButton : UIButton!
    @IBOutlet var loadingIndicator : UIActivityIndicatorView!
    @IBOutlet var lastUpdateLabel : UILabel!
    
    @IBOutlet var pointFilterBaseLabel: PointsFilterKeyView!
    @IBOutlet var airportsLabel : UILabel!
    @IBOutlet var heliportsLabel : UILabel!
    
    var viewModel : MapViewModel!
    
    private let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadButton.titleLabel?.numberOfLines = 0
        self.mapTypeControl.selectedSegmentIndex = Int(Settings.current.mapType.value.rawValue)
        
        self.lastUpdateLabel.reactive.text <~ Settings.current.lastUpdate.map({ [weak self] date in
            return "Menu_Last_Update_Format".localized(arguments: self?.dateFormatter.string(from: date) ?? "")
        })
        
        self.distanceUnitsControl.removeAllSegments()
        self.distanceUnitsControl.insertSegment(withTitle: DistanceUnits.meter.localized, at: DistanceUnits.meter.rawValue, animated: false)
        self.distanceUnitsControl.insertSegment(withTitle: DistanceUnits.foot.localized, at: DistanceUnits.foot.rawValue, animated: false)
        self.distanceUnitsControl.selectedSegmentIndex = Settings.current.units.value.distance.rawValue
        
        self.pressureControl.removeAllSegments()
        self.pressureControl.insertSegment(withTitle: PressureUnits.mmHg.localized, at: PressureUnits.mmHg.rawValue, animated: false)
        self.pressureControl.insertSegment(withTitle: PressureUnits.hPa.localized, at: PressureUnits.hPa.rawValue, animated: false)
        self.pressureControl.insertSegment(withTitle: PressureUnits.inHg.localized, at: PressureUnits.inHg.rawValue, animated: false)
        self.pressureControl.selectedSegmentIndex = Settings.current.units.value.pressure.rawValue
        
        self.viewModel.isLoading.producer.startWithValues { [weak self] isLoading in
            self?.reloadButton.isHidden = isLoading
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
        }
        
        self.pointFilterBaseLabel.settingsType = PointsFilter.Base.self
        Settings.current.pointsFilter.producer.startWithValues { [weak self] filter in
            let airportsString = NSMutableAttributedString()
            airportsString.append(NSAttributedString(string: AppIcons.MakiAirfield.rawValue, attributes: [
                NSFontAttributeName : UIFont.makiFont(ofSize: 14)
                ]))
            airportsString.append(NSAttributedString(string: "\n\(filter.airportsState.localized)", attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 12)
                ]))
                
            self?.airportsLabel.attributedText = airportsString
            
            let heliportsString = NSMutableAttributedString()
            heliportsString.append(NSAttributedString(string: AppIcons.MakiHeliport.rawValue, attributes: [
                NSFontAttributeName : UIFont.makiFont(ofSize: 14)
                ]))
            heliportsString.append(NSAttributedString(string: "\n\(filter.heliportsState.localized)", attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 12)
                ]))
            
            self?.airportsLabel.attributedText = heliportsString
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl!) {
        if let mapType = MKMapType(rawValue: UInt(sender.selectedSegmentIndex)) {
            Settings.current.mapType.value = mapType
        }
    }
    
    @IBAction func distanceUnitsChanged(_ sender: UISegmentedControl!) {
        if let distanceUnits = DistanceUnits(rawValue: sender.selectedSegmentIndex) {
            var units = Settings.current.units.value
            units.distance = distanceUnits
            Settings.current.units.value = units
        }
    }
    
    @IBAction func pressureUnitsChanged(_ sender: UISegmentedControl!) {
        if let pressureUnits = PressureUnits(rawValue: sender.selectedSegmentIndex) {
            var units = Settings.current.units.value
            units.pressure = pressureUnits
            Settings.current.units.value = units
        }
    }
    
    @IBAction func reloadAction(_ sender: AnyObject!) {
        let alert = UIAlertController(title: nil, message: "Menu_Reload_Message".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Button_Cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Menu_Reload_Button".localized, style: .default, handler: { [weak self] _ in
            self?.viewModel.loadAirfields(force: true)
        }))
        self.present(alert, animated: true)
    }

}
