//
//  DetailsCell.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/9/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

protocol DetailsCell {
    
    func configure(for object: PointDetailsViewModel.TableObject)
}

class TextDetailsCell : UITableViewCell, DetailsCell {
    func configure(for object: PointDetailsViewModel.TableObject) {
        self.textLabel?.text = object.text
    }
}

class DetailedDetailsCell : UITableViewCell, DetailsCell {
    func configure(for object: PointDetailsViewModel.TableObject) {
        self.textLabel?.text = object.text
        self.detailTextLabel?.text = object.details
    }
}

class ValueDetailsCell : UITableViewCell, DetailsCell {
    @IBOutlet var valueLabel : UILabel!
    
    func configure(for object: PointDetailsViewModel.TableObject) {
        self.textLabel?.text = object.text
        self.detailTextLabel?.text = object.details
        self.valueLabel.text = object.value
    }
}

class ItemsDetailsCell : UITableViewCell, DetailsCell {
    @IBOutlet var itemsView : UIStackView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        while itemsView.arrangedSubviews.count > 0 {
            let view = itemsView.arrangedSubviews.first!
            itemsView.removeArrangedSubview(view)
        }
    }
    
    func configure(for object: PointDetailsViewModel.TableObject) {
        self.textLabel?.text = object.text
        self.detailTextLabel?.text = object.details
        
        
    }
}
