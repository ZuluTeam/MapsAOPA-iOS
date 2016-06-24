//
//  PointDetailsView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/2/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class PointDetailsView: UIView
{
    weak var delegate : PointDetailsDelegate?
    
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var runwaysView : RunwaysView?
    @IBOutlet weak var altitudeLabel : UILabel?
    @IBOutlet weak var callButton : UIButton?
    @IBOutlet weak var websiteButton : UIButton?
    @IBOutlet weak var emailButton : UIButton?
    @IBOutlet weak var fuelLabel : UILabel?
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
        self.callButton?.hidden = ((point?.details?.contacts as? [AnyObject])?.count ?? 0) <= 0
        if let frequencies = point?.details?.frequencies as? [[String:String]]
        {
            self.frequencyLabel?.hidden = 1 < frequencies.count
            self.frequenciesButton?.hidden = 1 == frequencies.count
            if let freq = frequencies.first
            {
                self.frequencyLabel?.text = "📻: \(freq["callsign"] ?? "") \(freq["freq"] ?? "")MHz"
            }
            else
            {
                self.frequencyLabel?.text = "📻: unknown"
            }
        }
        self.fuelLabel?.hidden = true
        if let fuels = point?.fuel as? Set<Fuel> where fuels.count > 0
        {
            self.fuelLabel?.hidden = false
            let fuelString = Array(fuels)
                .sort({ $0.type?.longValue ?? 0 < $1.type?.longValue ?? 0 })
                .map({ FuelType(rawValue: $0.type?.longValue ?? 0)?.description() ?? "" })
                .filter({ $0.length > 0 })
                .joinWithSeparator(", ")
            self.fuelLabel?.text = "⛽️: " + fuelString
        }
        else
        {
            self.fuelLabel?.text = "⛽️: unknown"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func emailAction(sender: AnyObject?)
    {
        if let email = self.point?.details?.email
        {
            self.delegate?.sendEmail(email)
        }
    }
    
    @IBAction func frequenciesAction(sender: AnyObject?)
    {
        
    }
    
    @IBAction func websiteAction(sender: AnyObject?)
    {
        if var website = point?.details?.website
        {
            if(!website.containsString("://"))
            {
                website = "http://" + website
            }
            if let url = NSURL(string: website) where UIApplication.sharedApplication().canOpenURL(url)
            {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    @IBAction func runwaysAction(sender: AnyObject?)
    {
        
    }
}

protocol PointDetailsDelegate: class
{
    func sendEmail(email : String)
}


