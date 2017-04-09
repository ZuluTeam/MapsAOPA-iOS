//
//  OneWayTransformOf.swift
//  MapsAOPA
//
//  Created by Ekaterina Zyryanova on 2017-04-06.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ObjectMapper

open class TransformJSONOf<ObjectType, JSONType>: TransformType {
    public typealias Object = ObjectType
    public typealias JSON = JSONType
    
    private let fromJSON: ((JSONType?) -> ObjectType?)?
    private let toJSON: ((ObjectType?) -> JSONType?)?
    
    public init(fromJSON: @escaping (JSONType?) -> ObjectType?, toJSON: @escaping (ObjectType?) -> JSONType?) {
        self.fromJSON = fromJSON
        self.toJSON = toJSON
    }
    
    public init(fromJSON: @escaping (JSONType?) -> ObjectType?) {
        self.fromJSON = fromJSON
        self.toJSON = nil
    }
    
    public init(toJSON: @escaping (ObjectType?) -> JSONType?) {
        self.toJSON = toJSON
        self.fromJSON = nil
    }
    
    open func transformFromJSON(_ value: Any?) -> ObjectType? {
        return fromJSON?(value as? JSONType)
    }
    
    open func transformToJSON(_ value: ObjectType?) -> JSONType? {
        return toJSON?(value)
    }
}
