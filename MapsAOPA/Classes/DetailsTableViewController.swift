//
//  DetailsTableViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/23/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

enum DetailsReuseIdentifier : String
{
    case ContactsCell
    case FrequenciesCell
}

class DetailsTableViewController: UITableViewController {
    
    var cellReuseIdentifier : String = ""
    var objects : [[String:AnyObject]]?

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseIdentifier, forIndexPath: indexPath) as? DetailsTableViewCell
        cell?.object = self.objects?[indexPath.row]
        return cell as! UITableViewCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? DetailsTableViewCell
        {
            cell.action()
        }
    }
}
