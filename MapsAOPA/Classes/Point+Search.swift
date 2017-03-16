//
//  Point+Search.swift
//  MapsAOPA
//
//  Created by Kate on 28/02/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import CoreData

extension Point {
    
    public static func searchPredicate(_ searchString: String) -> NSPredicate {
        let normalizedString = searchString.normalizedString ?? ""
        return NSPredicate(format: "%K contains[n] %@ OR %K contains[n] %@ OR %K contains[n] %@ OR %K contains[n] %@ OR %K contains[n] %@ OR %K contains[n] %@",
                           Point.Keys.searchIndex.rawValue, normalizedString,
                           Point.Keys.searchIndexRu.rawValue, normalizedString,
                           Point.Keys.searchCity.rawValue, normalizedString,
                           Point.Keys.searchRegion.rawValue, normalizedString,
                           Point.Keys.searchTitle.rawValue, normalizedString,
                           Point.Keys.searchTitleRu.rawValue, normalizedString)
    }
    
    public static func searchByRegionPredicate(_ searchString: String) -> NSPredicate {
        return predicateForString(searchString, with: Point.Keys.searchRegion.rawValue)
    }
    
    public static func searchByIndexPredicate(_ searchString: String) -> NSPredicate {
        return predicateForString(searchString, with: Point.Keys.searchIndex.rawValue, and: Point.Keys.searchIndexRu.rawValue)
    }
    
    public static func searchByCityPredicate(_ searchString: String) -> NSPredicate {
        return predicateForString(searchString, with: Point.Keys.searchCity.rawValue)
    }
    
    public static func searchByTitle(_ searchString : String) -> NSPredicate {
        return predicateForString(searchString, with: Point.Keys.searchTitle.rawValue, and: Point.Keys.searchTitleRu.rawValue)
    }
    
    
    private static func predicateForString(_ string: String, with key: String) -> NSPredicate {
        let normalizedString = string.normalizedString ?? ""
        return NSPredicate(format: "%K contains[n] %@", key, normalizedString)
    }
    
    private static func predicateForString(_ string: String, with key: String, and ruKey: String) -> NSPredicate {
        let normalizedString = string.normalizedString ?? ""
        return NSPredicate(format: "%K contains[n] %@ OR %K contains[n] %@", key, normalizedString, ruKey, normalizedString)
    }
    
}

extension String {
    
    public var normalizedString : String? {
        let transformed : String?
        if #available(iOS 9.0, *) {
            transformed = applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower; [:^Letter:] Remove"), reverse: false)
        } else {
            transformed = self.transliterated(language: "en").lowercased()
        }
        return transformed
    }
    
}
