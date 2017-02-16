//
//  MapViewModel.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/20/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import MapKit
import ReactiveSwift
import Result

class MapViewModel
{
    var isLoading : Property<Bool> { return Property(_loading) }
    var errorMessage : Property<String?> { return Property(_errorMessage) }
    
    fileprivate let _loading = MutableProperty<Bool>(false)
    fileprivate let _errorMessage = MutableProperty<String?>(nil)
    
    fileprivate let network : Network
    fileprivate let loader : AOPALoader
    
    fileprivate var xmlParser : ItemsXMLParser?
    
    init() {
        self.network = Network()
        self.loader = AOPALoader(network: network)
    }
    
    func loadAirfields(force: Bool = false) {
        let date = Date()
        if !force && date.timeIntervalSince(Settings.lastUpdate) < Settings.reloadDataTimeInterval {
            return
        }
        _loading.value = true
        
        self.loader.loadAirfields().flatMap(.latest, transform: { [weak self] (url : URL) -> SignalProducer<Any, AOPAError> in
            self?.xmlParser = ItemsXMLParser(contentsOf: url, forItems: "point")
            if let xmlParser = self?.xmlParser {
                return xmlParser.parse().mapError({ AOPAError($0) })
            }
            return .empty
        }).on(failed: { [weak self] error in
            print(error.description)
            self?._errorMessage.value = error.description
            },
              completed: { [weak self] in
                self?.xmlParser = nil
                self?._loading.value = false
                Settings.lastUpdate = Date()
                Database.sharedDatabase.saveContext(Database.sharedDatabase.backgroundManagedObjectContext)
            },
              value: { value in
                if let pointDict = value as? [String:AnyObject] {
                    let _ = Point.point(fromDictionary: pointDict, inContext: Database.sharedDatabase.backgroundManagedObjectContext)
                }
        }).start()
    }    
}
