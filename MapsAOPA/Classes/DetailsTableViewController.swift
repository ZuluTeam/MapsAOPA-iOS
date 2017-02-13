//
//  DetailsTableViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/23/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import Sugar

enum DetailsReuseIdentifier : String
{
    case DefaultCell
    case ContactsCell
    case FrequenciesCell
    
    var cellClass : String
    {
        switch self {
        case .DefaultCell: return ""
        case .ContactsCell: return "PhoneTableViewCell"
        case .FrequenciesCell: return "FrequenciesTableViewCell"
        }
    }
}

class DetailsTableViewController: UITableViewController {
    
    var cellReuseIdentifier : DetailsReuseIdentifier = .DefaultCell
    var objects : [[String:AnyObject]]?
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if !UIInterfaceOrientationIsPortrait(toInterfaceOrientation)
        {
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.title
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier.rawValue, for: indexPath) as? DetailsTableViewCell
        cell?.object = self.objects?[indexPath.row]
        return cell!
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if let object = self.objects?[indexPath.row]
//        {
//            (SwiftClassFromString(self.cellReuseIdentifier.cellClass) as? DetailsTableViewCell.Type)?.action(forObject: object)
//        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
//        let object = self.objects?[indexPath.row] ?? [:]
//        return (SwiftClassFromString(self.cellReuseIdentifier.cellClass) as? DetailsTableViewCell.Type)?.cellHeight(forObject: object) ?? 0.0
    }
}
