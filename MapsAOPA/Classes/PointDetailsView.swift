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
    
    fileprivate func reloadView() {
//        self.titleLabel?.text = "\(point?.titleRu ?? "") \(point?.index ?? "")/\(point?.indexRu ?? "")"
        self.altitudeLabel?.text = "Altitude: \(point?.details?.altitude ?? 0)m"
        self.runwaysView?.runways = point?.runways as? Set<Runway>
        self.emailButton?.isHidden = nil == point?.details?.email
        self.websiteButton?.isHidden = nil == point?.details?.website
        self.frequencyLabel?.isHidden = true
        self.frequenciesButton?.isHidden = true
        self.callButton?.isHidden = ((point?.details?.contacts as? [AnyObject])?.count ?? 0) <= 0
        if let frequencies = point?.details?.frequencies as? [[String:String]]
        {
            self.frequencyLabel?.isHidden = 1 < frequencies.count
            self.frequenciesButton?.isHidden = 1 == frequencies.count
            if let freq = frequencies.first
            {
                self.frequencyLabel?.text = "📻: \(freq["callsign"] ?? "") \(freq["freq"] ?? "")MHz"
            }
            else
            {
                self.frequencyLabel?.text = "📻: unknown"
            }
        }
        self.fuelLabel?.isHidden = true
        if let fuels = point?.fuel as? Set<Fuel>, fuels.count > 0
        {
            self.fuelLabel?.isHidden = false
            let fuelString = Array(fuels)
                .sorted(by: { $0.type?.intValue ?? 0 < $1.type?.intValue ?? 0 })
                .map({ FuelType(rawValue: $0.type?.intValue ?? 0)?.description() ?? "" })
                .filter({ $0.length > 0 })
                .joined(separator: ", ")
            self.fuelLabel?.text = "⛽️: " + fuelString
        }
        else
        {
            self.fuelLabel?.text = "⛽️: unknown"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func emailAction(_ sender: AnyObject?)
    {
        if let email = self.point?.details?.email
        {
            self.delegate?.sendEmail(email)
        }
    }
    
    @IBAction func frequenciesAction(_ sender: AnyObject?)
    {
        
    }
    
    @IBAction func websiteAction(_ sender: AnyObject?)
    {
        if var website = point?.details?.website
        {
            if(!website.contains("://"))
            {
                website = "http://" + website
            }
            if let url = URL(string: website), UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func runwaysAction(_ sender: AnyObject?)
    {
        
    }
}

protocol PointDetailsDelegate: class
{
    func sendEmail(_ email : String)
}


