//
//  RunwaysView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/2/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class RunwaysView: UIView {
    
    var runways : [RunwayViewModel] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }

    
    override func draw(_ rect: CGRect) {
        
        
        
    }
    

}
