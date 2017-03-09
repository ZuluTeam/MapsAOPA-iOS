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
class PointDetailsView: UIView, UITableViewDataSource
{
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var runwaysView : RunwaysView?
    @IBOutlet weak var elevationLabel : UILabel?
    @IBOutlet weak var longestRunwayLabel : UILabel?
    @IBOutlet weak var callButton : UIButton?
    @IBOutlet weak var websiteButton : UIButton?
    @IBOutlet weak var emailButton : UIButton?
    @IBOutlet weak var fuelLabel : UILabel?
    @IBOutlet weak var frequenciesButton : UIButton?
    @IBOutlet weak var frequencyLabel : UILabel?

    @IBOutlet weak var tableView : UITableView?
    
    private let transliteration = UCCTransliteration()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 100
    }
    
    var pointDetailsViewModel : PointDetailsViewModel? {
        didSet {
            self.reloadView()
            self.tableView?.reloadData()
        }
    }
    
    fileprivate func reloadView() {
        guard let model = pointDetailsViewModel else {
            return
        }
        
        self.titleLabel?.text = model.title
        self.elevationLabel?.text = "Details_Elevation_Format".localized(arguments: Converter.localized(distanceInMeters: model.elevation))
        self.fuelLabel?.text = !model.fuels.isEmpty ? "⛽️: " + model.fuels : nil
        self.frequenciesButton?.isHidden = model.frequencies.count <= 1
        if let frequency = model.frequencies.first, model.frequencies.count <= 1 {
            self.frequencyLabel?.isHidden = false
            self.frequencyLabel?.text = "Details_Frequencies_Format".localized(arguments: frequency.callsign, frequency.frequency)
        } else {
            self.frequencyLabel?.isHidden = true
        }
        
        let longestRunwayLength = model.runways.reduce(0, { $0 > $1.length ? $0 : $1.length })
        self.longestRunwayLabel?.text = "Details_Longest_Runway_Format".localized(arguments: Converter.localized(distanceInMeters: longestRunwayLength))
        self.longestRunwayLabel?.isHidden = longestRunwayLength <= 0
        
        self.callButton?.isHidden = model.contacts.count <= 0
        self.websiteButton?.isHidden = model.website == nil
        self.emailButton?.isHidden = model.email == nil
        
        self.runwaysView?.runways = model.runways
        self.runwaysView?.isHeliport = model.type == .heliport
    }
    
    // MARK: - Table view data source
    
    func object(at indexPath: IndexPath) -> PointDetailsViewModel.TableObject {
        return self.pointDetailsViewModel!.tableViewObjects[indexPath.section].objects[indexPath.row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.pointDetailsViewModel?.tableViewObjects.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pointDetailsViewModel?.tableViewObjects[section].objects.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath)
        
        cell.textLabel?.text = object.text
        cell.detailTextLabel?.text = object.details
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.pointDetailsViewModel!.tableViewObjects[section]
        return section.sectionTitle
    }
}

