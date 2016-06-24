//
//  DetailsTableViewCell.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/23/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class DetailsTableViewCell : UITableViewCell
{
    var object : [String:AnyObject]?
    
    class func action(forObject object: AnyObject) {}
    class func cellHeight(forObject object: AnyObject) -> CGFloat { return 0.0 }
}
