//
//  Converter.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/22/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation

class Converter {
    static let hPatoMmHg : Double = 1.33322
    static let feetToM : Double = 0.3048
    
    static func mmHg(fromhPa hPa: Double) -> Double {
        return hPa * hPatoMmHg
    }
    
    static func hPa(fromMmHg mmHg: Double) -> Double {
        return mmHg / hPatoMmHg
    }
    
    static func meters(fromFeet feet: Double) -> Double {
        return feet * feetToM
    }
    
    static func feet(fromMeters meters: Double) -> Double {
        return meters / feetToM
    }
    
    
}
