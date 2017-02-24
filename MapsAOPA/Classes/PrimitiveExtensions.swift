//
//  StringExtensions.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreGraphics
import UCCTransliteration
import MapKit

extension String {
    func transliterated(language: String) -> String {
        let transliteration = UCCTransliteration()
        if language != "ru" {
            return transliteration.transliterate(self)
        }
        return self
    }
    
    func localized(_ comment: String = "") -> String {
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

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2))
    }
    
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static prefix func -(right: CGPoint) -> CGPoint {
        return CGPoint(x: -right.x, y: -right.y)
    }
}

extension MKMapPoint {
    func distance(from point: MKMapPoint) -> Double {
        return sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2))
    }
    
    static func +(left: MKMapPoint, right: MKMapPoint) -> MKMapPoint {
        return MKMapPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func -(left: MKMapPoint, right: MKMapPoint) -> MKMapPoint {
        return MKMapPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static prefix func -(right: MKMapPoint) -> MKMapPoint {
        return MKMapPoint(x: -right.x, y: -right.y)
    }
}
