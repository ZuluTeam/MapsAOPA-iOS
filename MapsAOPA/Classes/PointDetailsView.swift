//
//  PointDetailsView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/2/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import MessageUI

class PointDetailsView: UIView
{
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var runwaysView : RunwaysView?
    @IBOutlet weak var altitudeLabel : UILabel?
    @IBOutlet weak var callButton : UIButton?
    @IBOutlet weak var websiteButton : UIButton?
    @IBOutlet weak var emailButton : UIButton?
    @IBOutlet weak var fuelView : UIView?
    @IBOutlet weak var frequenciesButton : UIButton?
    @IBOutlet weak var frequencyLabel : UILabel?
    
    
    @IBOutlet weak var tableView : UITableView?
    
    var point : Point? {
        didSet {
            self.reloadView()
        }
    }
    
    private func reloadView() {
        self.titleLabel?.text = "\(point?.titleRu ?? "") \(point?.index ?? "")/\(point?.indexRu ?? "")"
        self.altitudeLabel?.text = "Altitude: \(point?.details?.altitude ?? 0)m"
        self.runwaysView?.runways = point?.runways as? Set<Runway>
        self.emailButton?.hidden = nil == point?.details?.email
        self.websiteButton?.hidden = nil == point?.details?.website
        self.frequencyLabel?.hidden = true
        self.frequenciesButton?.hidden = true
        if let frequencies = point?.details?.frequencies as? [[String:String]]
        {
            self.frequencyLabel?.hidden = 1 < frequencies.count
            self.frequenciesButton?.hidden = 1 == frequencies.count
            if let freq = frequencies.first
            {
                self.frequencyLabel?.text = "\(freq["callsign"] ?? "") : \(freq["freq"] ?? "")MHz"
            }
        }
    }
}