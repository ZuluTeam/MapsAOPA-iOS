//
//  StringExtensions.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation

extension String {
    func localized(_ comment: String = "") -> String
    {
        return NSLocalizedString(self, comment: comment)
    }
    
    var length : Int {
        get {
            return (self as NSString).length
        }
    }
}
