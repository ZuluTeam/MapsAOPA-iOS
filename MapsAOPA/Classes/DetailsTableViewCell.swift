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
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var subtitleLabel : UILabel?
    @IBOutlet weak var valueLabel : UILabel?
    
    var viewModel : DetailsCellViewModel? {
        didSet {
            titleLabel?.text = viewModel?.title
            subtitleLabel?.text = viewModel?.subtitle
            valueLabel?.text = viewModel?.value
        }
    }
}
