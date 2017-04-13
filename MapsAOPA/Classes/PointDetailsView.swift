//
//  PointDetailsView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/2/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import UCCTransliteration
import ReactiveSwift

class PointDetailsView: UIView
{
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var runwaysView : RunwaysView?
    @IBOutlet weak var elevationLabel : UILabel!
    @IBOutlet weak var longestRunwayLabel : UILabel!
    @IBOutlet weak var callButton : UIButton?
    @IBOutlet weak var websiteButton : UIButton?
    @IBOutlet weak var emailButton : UIButton?
    @IBOutlet weak var fuelLabel : UILabel?
    @IBOutlet weak var frequenciesButton : UIButton?
    @IBOutlet weak var frequencyLabel : UILabel?
    
    private let transliteration = UCCTransliteration()
    
    static func view(model: PointDetailsViewModel) -> PointDetailsView? {
        let view = Bundle.main.loadNibNamed("PointDetailsView", owner: nil, options: nil)?.first as? PointDetailsView
        view?.pointDetailsViewModel = model
        return view
    }
    
    var pointDetailsViewModel : PointDetailsViewModel? {
        didSet {
            self.reloadView()
        }
    }
    
    fileprivate func reloadView() {
        guard let model = pointDetailsViewModel else {
            return
        }
        
        self.titleLabel?.text = model.title
        
        let elevation = model.elevation
        
        self.elevationLabel.reactive.text <~ Settings.current.units.map({ _ in
            return "Details_Elevation_Format".localized(arguments: "\(Converter.localized(distanceInMeters: elevation)) (\(Converter.localized(pressureDegreeFromMeters: Double(elevation))))")
        })
        let longestRunwayLength = model.runways.reduce(0, { $0 > $1.length ? $0 : $1.length })
        self.longestRunwayLabel.reactive.text <~ Settings.current.units.map({ _ in
            return "Details_Longest_Runway_Format".localized(arguments: Converter.localized(distanceInMeters: longestRunwayLength))
        })
        self.longestRunwayLabel.isHidden = longestRunwayLength <= 0
        
        self.fuelLabel?.text = !model.fuels.isEmpty ? "⛽️: " + model.fuels : nil
        self.frequenciesButton?.isHidden = model.frequencies.count <= 1
        if let frequency = model.frequencies.first, model.frequencies.count <= 1 {
            self.frequencyLabel?.isHidden = false
            self.frequencyLabel?.text = "Details_Frequencies_Format".localized(arguments: frequency.callsign, frequency.frequency)
        } else {
            self.frequencyLabel?.isHidden = true
        }
        
        
        self.callButton?.isHidden = model.contacts.count <= 0
        self.websiteButton?.isHidden = model.website == nil
        self.emailButton?.isHidden = model.email == nil
        
        self.runwaysView?.runways = model.runways
        self.runwaysView?.isHeliport = model.type == .heliport
    }
}

