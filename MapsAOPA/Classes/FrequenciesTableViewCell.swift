//
//  FrequenciesTableViewCell.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/24/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class FrequenciesTableViewCell: DetailsTableViewCell {
    @IBOutlet weak var typeLabel : UILabel?
    @IBOutlet weak var frequencyLabel : UILabel?
    @IBOutlet weak var callsignLabel : UILabel?
    
    override var object : [String:AnyObject]? {
        didSet {
            self.updateObject()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.typeLabel?.text = nil
        self.frequencyLabel?.text = nil
        self.callsignLabel?.text = nil
    }
    
    // MARK: - Private
    
    fileprivate func updateObject()
    {
        self.typeLabel?.text = self.object?["type"] as? String
        self.frequencyLabel?.text = self.object?["freq"] as? String
        self.callsignLabel?.text = self.object?["callsign"] as? String
    }
    
    // MARK: - DetailsTableViewCell
    
    override static func cellHeight(forObject object: AnyObject) -> CGFloat
    {
        return 64.0
    }
}
