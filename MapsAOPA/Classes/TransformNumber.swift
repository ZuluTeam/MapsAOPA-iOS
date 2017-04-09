//
//  TransformNumber.swift
//  MapsAOPA
//
//  Created by Ekaterina Zyryanova on 2017-04-09.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ObjectMapper

open class TransformDoubleValue: TransformType {
    public typealias Object = Double
    public typealias JSON = String
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        if let number = value as? Double {
            return number
        } else if let string = value as? String {
            return Double(string)
        }
        return nil
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        return String(describing: value)
    }
}

open class TransformIntValue: TransformType {
    public typealias Object = Int
    public typealias JSON = String
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        if let number = value as? Int {
            return number
        } else if let string = value as? String {
            return Int(string)
        }
        return nil
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        return String(describing: value)
    }
}

open class TransformBoolValue: TransformType {
    public typealias Object = Bool
    public typealias JSON = String
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        if let number = value as? Bool {
            return number
        } else if let string = value as? String {
            return Bool(string)
        }
        return nil
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        return String(describing: value)
    }
}
