//
//  DetailsTableViewCell.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/23/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

protocol DetailsTableViewCell
{
    var object : [String:AnyObject]? { get set }
    
    static func action(forObject object: AnyObject)
    static func cellHeight(forObject object: AnyObject) -> CGFloat
}
