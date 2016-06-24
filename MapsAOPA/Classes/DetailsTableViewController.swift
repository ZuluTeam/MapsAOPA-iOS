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
        case .FrequenciesCell: return ""
        }
    }
}

class DetailsTableViewController: UITableViewController {
    
    var cellReuseIdentifier : DetailsReuseIdentifier = .DefaultCell
    var objects : [[String:AnyObject]]?

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseIdentifier.rawValue, forIndexPath: indexPath) as? DetailsTableViewCell
        cell?.object = self.objects?[indexPath.row]
        return cell as! UITableViewCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let object = self.objects?[indexPath.row]
        {
            (SwiftClassFromString(self.cellReuseIdentifier.cellClass) as? DetailsTableViewCell.Type)?.action(forObject: object)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let object = self.objects?[indexPath.row] ?? [:]
        return (SwiftClassFromString(self.cellReuseIdentifier.cellClass) as? DetailsTableViewCell.Type)?.cellHeight(forObject: object) ?? 0.0
    }
}
