//
//  ValueTransformer.swift
//  MapsAOPA
//
//  Created by Kate on 01/03/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//  inspired by 2015 objc.io. All rights reserved.

import Foundation

class ValueTransform<A: Any, B: AnyObject>: ValueTransformer {
    
    typealias Transform = (A?) -> B?
    typealias ReverseTransform = (B?) -> A?

    fileprivate let transform : Transform
    fileprivate let reverseTransform : ReverseTransform
    
    static func registerValueTransformerWithName(_ name: String, transform: @escaping Transform, reverseTransform: @escaping ReverseTransform) {
        let transformer = ValueTransform(transform: transform, reverseTransform: reverseTransform)
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: name))
    }
    
    init(transform: @escaping Transform, reverseTransform: @escaping ReverseTransform) {
        self.transform = transform
        self.reverseTransform = reverseTransform
        super.init()
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        return transform(value as? A)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        return reverseTransform(value as? B)
    }
    
    override class func transformedValueClass() -> AnyClass {
        return B.self
    }
    
    override static func allowsReverseTransformation() -> Bool {
        return true
    }
}
