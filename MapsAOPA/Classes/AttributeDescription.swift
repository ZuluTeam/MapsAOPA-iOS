//
//  AttributeDescription.swift
//  MapsAOPA
//
//  Created by Kate on 23/02/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

extension NSAttributeDescription {
    
    private static let defaultDateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
    
    public func checkValue(_ value: AnyObject?) -> NSObject? {
        
        guard let value = value else {
            return nil
        }
        
        let attributeType = self.attributeType
        switch attributeType {
        case .dateAttributeType:
            let dateFormat : String = self.userInfo?[ManagedObjectImportKeys.customDateFormatKey.rawValue] as? String ?? NSAttributeDescription.defaultDateFormat
            
            if let value = value as? NSNumber {
                return date(from: value, milliseconds: dateFormat == ManagedObjectImportKeys.unixTimeString.rawValue)
            } else if let value = value as? String {
                return date(from: value, format: dateFormat)
            } else if let value = value as? NSDate {
                return value
            }
            return nil
            
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType, .decimalAttributeType, .doubleAttributeType, .floatAttributeType :
            if let value = value as? NSString {
                return NSNumber(value: value.doubleValue)
            }
            return value as? NSNumber
        case .booleanAttributeType :
            if let value = value as? NSString {
                return NSNumber(value: value.boolValue)
            }
            return value as? NSNumber
        case .stringAttributeType :
            return value as? NSString
        default:
            return value as? NSObject
        }
        
    }
    
    private func date(from string: String?, format: String) -> NSDate? {
        
        guard let string = string else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        formatter.dateFormat = format
        
        return formatter.date(from: string) as NSDate?
    }
    
    private func date(from number: NSNumber?, milliseconds: Bool) -> NSDate? {
        
        guard let number = number else {
            return nil
        }
        
        var timeInterval = number.doubleValue
        if milliseconds {
            timeInterval = timeInterval / 1000.00
        }
        return Date(timeIntervalSince1970: timeInterval) as NSDate
    }
    
}
