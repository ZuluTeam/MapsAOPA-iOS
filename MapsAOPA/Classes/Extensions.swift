//
//  Extensions.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

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

struct AssociationKey {
    static var hidden: UInt8 = 1
    static var alpha: UInt8 = 2
    static var text: UInt8 = 3
    static var enabled : UInt8 = 4
}

// lazily creates a gettable associated property via the given factory
func lazyAssociatedProperty<T: AnyObject>(_ host: AnyObject, key: UnsafeRawPointer, factory: ()->T) -> T {
    return objc_getAssociatedObject(host, key) as? T ?? {
        let associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return associatedProperty
        }()
}

func lazyMutableProperty<T>(_ host: AnyObject, key: UnsafeRawPointer, setter: @escaping (T) -> (), getter: @escaping () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key: key) {
        let property = MutableProperty<T>(getter())
        property.producer
            .startWithValues{
                newValue in
                setter(newValue)
        }
        
        return property
    }
}

extension UITextField {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, key: &AssociationKey.text) {
            
            self.addTarget(self, action: #selector(UITextField.changed), for: UIControlEvents.editingChanged)
            
            let property = MutableProperty<String>(self.text ?? "")
            property.producer
                .startWithValues {
                    newValue in
                    self.text = newValue
            }
            return property
        }
    }
    
    func changed() {
        rac_text.value = self.text ?? ""
    }
}

func SwiftClassFromString(_ className: NSString) -> AnyClass?
{
    if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    {
        let classStringName = "_TtC\(appName.length)\(appName)\(className.length)\(className)"
        return NSClassFromString(classStringName);
    }
    return nil
}
