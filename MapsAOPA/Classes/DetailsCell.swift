//
//  DetailsCell.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/9/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import Alamofire

protocol DetailsCell {
    
    func configure(with object: PointDetailsViewModel.TableObject)
}

class TextDetailsCell : UITableViewCell, DetailsCell {
    @IBOutlet var mainTextLabel : UILabel?
    @IBOutlet var valueLabel : UILabel?
    
    func configure(with object: PointDetailsViewModel.TableObject) {
        self.mainTextLabel?.text = object.text
        self.valueLabel?.text = object.value
        if let font = self.valueLabel?.font, let size = object.value?.size(attributes: [ NSFontAttributeName : font ]) {
            for constraint in self.valueLabel?.constraints ?? [] {
                if constraint.identifier == "width" {
                    constraint.constant = ceil(size.width)
                }
            }
        }
    }
}

class DetailedDetailsCell : TextDetailsCell {
    @IBOutlet var detailsLabel: UILabel?
    
    override func configure(with object: PointDetailsViewModel.TableObject) {
        super.configure(with: object)
        self.detailsLabel?.text = object.details
    }
}

class ValueDetailsCell : DetailedDetailsCell {
    
    override func configure(with object: PointDetailsViewModel.TableObject) {
        super.configure(with: object)
    }
}

class ItemsDetailsCell : DetailedDetailsCell {
    @IBOutlet var itemsView : UIStackView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        while itemsView?.arrangedSubviews.count ?? 0 > 0 {
            if let view = itemsView?.arrangedSubviews.first {
                itemsView?.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
    }
    
    override func configure(with object: PointDetailsViewModel.TableObject) {
        super.configure(with: object)
        if let items = object.items {
            for item in items {
                if let view = DetailsItemView.view(with: item) {
                    self.itemsView?.addArrangedSubview(view)
                }
            }
        }
    }
}

class ImageDetailsCell : UITableViewCell, DetailsCell {
    @IBOutlet var mainImageView : UIImageView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImageView?.af_cancelImageRequest()
        mainImageView?.image = nil
    }
    
    func configure(with object: PointDetailsViewModel.TableObject) {
        if let url = object.imageURL {
            mainImageView?.af_setImage(withURL: url)
        }
    }
}
