//
//  DetailsItemView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/13/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class DetailsItemView: UIView {
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var valueLabel : UILabel!
    
    class func view(with item: (title: String, value: String)) -> DetailsItemView? {
        if let view = Bundle.main.loadNibNamed("DetailsItemView", owner: nil, options: nil)?.first as? DetailsItemView {
            view.setItem(item)
            return view
        }
        return nil
    }
    
    func setItem(_ item : (title: String, value: String)) {
        self.titleLabel.text = item.title
        self.valueLabel.text = item.value
        let size = item.value.size(attributes: [ NSFontAttributeName : self.valueLabel.font ])
        for constraint in self.valueLabel.constraints {
            if constraint.identifier == "width" {
                constraint.constant = ceil(size.width)
            }
        }
    }

}
