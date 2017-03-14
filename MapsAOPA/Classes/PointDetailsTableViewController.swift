//
//  PointDetailsTableViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/13/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class PointDetailsTableViewController: UITableViewController {
    var pointDetailsViewModel : PointDetailsViewModel? {
        didSet {
            self.tableView?.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 300
    }

    // MARK: - Table view data source
    
    private func cellIdentifier(for object: PointDetailsViewModel.TableObject) -> String {
        let object = (object.text != nil, object.details != nil, object.value != nil, object.items != nil, object.imageURL != nil)
        switch object {
        case (_, _, _, _, true): return "ImageDetailsCell"
        case (_, _, _, true, _): return "ItemsDetailsCell"
        case (true, true, true, _, _): return "ValueDetailsCell"
        case (_, true, true, _, _): return "DetailsOnlyDetailsCell"
        case (true, true, _, _, _): return "DetailedDetailsCell"
        default:
            return "TextDetailsCell"
        }
    }
    
    func object(at indexPath: IndexPath) -> PointDetailsViewModel.TableObject {
        return self.pointDetailsViewModel!.tableViewObjects[indexPath.section].objects[indexPath.row]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.pointDetailsViewModel?.tableViewObjects.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pointDetailsViewModel?.tableViewObjects[section].objects.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.object(at: indexPath)
        let identifier = self.cellIdentifier(for: object)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DetailsCell
        
        cell.configure(with: object)
        (cell as! UITableViewCell).setNeedsLayout()
        if nil != object.action {
            (cell as! UITableViewCell).selectionStyle = .gray
        } else {
            (cell as! UITableViewCell).selectionStyle = .none
        }
        return cell as! UITableViewCell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.pointDetailsViewModel!.tableViewObjects[section]
        return section.sectionTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let object = self.object(at: indexPath)
        if let action = object.action {
            switch action {
            case .call: self.call(phone: object.value)
            case .mail: self.mail(to: object.value)
            case .web: self.open(url: object.value)
            }
        }
    }
}
