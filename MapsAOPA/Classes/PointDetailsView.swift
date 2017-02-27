//
//  PointDetailsView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/2/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import UCCTransliteration

@IBDesignable
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
    
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer : CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    override func draw(_ rect: CGRect) {
        gradientLayer.colors = [ UIColor(hexString: "66CCFF").cgColor,
                                 UIColor(hexString: "0080FF").cgColor ]
    }
    
    fileprivate func reloadView() {
        guard let model = pointDetailsViewModel else {
            return
        }
        
        self.titleLabel?.text = model.title
        self.elevationLabel?.text = "Details_Elevation_Format_m".localized(arguments: model.elevation)
        self.fuelLabel?.text = !model.fuels.isEmpty ? "⛽️: " + model.fuels : nil
        self.frequenciesButton?.isHidden = model.frequencies.count <= 1
        if let frequency = model.frequencies.first, model.frequencies.count <= 1 {
            self.frequencyLabel?.isHidden = false
            let callsign = frequency.callsign.transliterated(language: Settings.language).capitalized
            self.frequencyLabel?.text = "Details_Frequencies_Format".localized(arguments: callsign, frequency.frequency)
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

