//
//  StringExtensions.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreGraphics

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
    
    func localized(_ comment : String = "", arguments: [CVarArg] ) -> String {
        let string = String(format: self.localized(comment), arguments: arguments)
        return string
    }
    
    func localized(_ comment : String = "", arguments: CVarArg...) -> String {
        let string = String(format: self.localized(comment), arguments: arguments)
        return string
    }
}


extension CGFloat {
    init(_ value: Bool) {
        self = value ? 1.0 : 0.0
    }
}

extension TimeInterval {
    init(_ value: Bool) {
        self = value ? 1.0 : 0.0
    }
}
