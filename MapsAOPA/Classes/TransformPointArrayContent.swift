//
//  TransformPointArrayContent.swift
//  MapsAOPA
//
//  Created by Ekaterina Zyryanova on 2017-04-06.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ObjectMapper

open class TransformPointArrayContent<ObjectType>: TransformType {
    public typealias Object = ObjectType
    public typealias JSON = Array<Dictionary<String, AnyObject>>
    
    private let fromJSON: ((JSON?) -> ObjectType?)?
    private let toJSON: ((ObjectType?) -> JSON?)?
    
    public init(fromJSON: @escaping (JSON?) -> ObjectType?, toJSON: @escaping (ObjectType?) -> JSON?) {
        self.fromJSON = fromJSON
        self.toJSON = toJSON
    }
    
    public init(fromJSON: @escaping (JSON?) -> ObjectType?) {
        self.fromJSON = fromJSON
        self.toJSON = nil
    }
    
    public init(toJSON: @escaping (ObjectType?) -> JSON?) {
        self.toJSON = toJSON
        self.fromJSON = nil
    }
    
    open func transformFromJSON(_ value: Any?) -> ObjectType? {
        var array = value as? [[String:AnyObject]]
        if let dict = value as? [String: AnyObject] {
            array = [dict]
        }
        
        return fromJSON?(array)
    }
    
    open func transformToJSON(_ value: ObjectType?) -> JSON? {
        return toJSON?(value)
    }
}
