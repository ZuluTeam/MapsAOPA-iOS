//
//  PointDetailsView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/2/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import UCCTransliteration

class PointDetailsView: UIView
{
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var runwaysView : RunwaysView?
    @IBOutlet weak var elevationLabel : UILabel?
    @IBOutlet weak var callButton : UIButton?
    @IBOutlet weak var websiteButton : UIButton?
    @IBOutlet weak var emailButton : UIButton?
    @IBOutlet weak var fuelLabel : UILabel?
    @IBOutlet weak var frequenciesButton : UIButton?
    @IBOutlet weak var frequencyLabel : UILabel?

    @IBOutlet weak var tableView : UITableView?
    
    private let transliteration = UCCTransliteration()
    
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
        self.elevationLabel?.text = "Details_Elevation_Format_m".localized(arguments: model.elevation)
        self.websiteButton?.isHidden = model.website == nil
        self.emailButton?.isHidden = model.email == nil
        self.fuelLabel?.text = !model.fuels.isEmpty ? "⛽️: " + model.fuels : nil
        self.frequenciesButton?.isHidden = model.frequencies.count <= 1
        if let frequency = model.frequencies.first, model.frequencies.count <= 1 {
            self.frequencyLabel?.isHidden = false
            var callsign = frequency.callsign
            if Settings.language != "ru" {
                callsign = transliteration.transliterate(frequency.callsign).capitalized
            }
            self.frequencyLabel?.text = "Details_Frequencies_Format".localized(arguments: callsign, frequency.frequency)
        } else {
            self.frequencyLabel?.isHidden = true
        }
        self.callButton?.isHidden = model.contacts.count <= 0
        self.runwaysView?.runways = model.runways
    }
}

