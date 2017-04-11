//
//  LoadingViewModel.swift
//  MapsAOPA
//
//  Created by Konstantin Zyrianov on 11/04/2017.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveSwift

class LoadingViewModel {
    var isLoading : Property<Bool> { return Property(_loading) }
    var errorMessage : Property<String?> { return Property(_errorMessage) }
    
    fileprivate let _loading = MutableProperty<Bool>(false)
    fileprivate let _errorMessage = MutableProperty<String?>(nil)
    
    fileprivate let network : Network
    fileprivate let loader : AOPALoader
    
    fileprivate var xmlParser : ArrayXMLParser?
    
    init() {
        self.network = Network()
        self.loader = AOPALoader(network: network)
    }
    
    func loadAirfields(force: Bool = false) {
        if _loading.value {
            return
        }
        let date = Date()
        let lastUpdate = Settings.current.lastUpdate.value
        if !force && nil != lastUpdate && date.timeIntervalSince(lastUpdate!) < Settings.reloadDataTimeInterval {
            return
        }
        _loading.value = true
        
        self.loader.loadAirfields().flatMap(.latest, transform: { [weak self] (url : URL) -> SignalProducer<Any, AOPAError> in
            self?.xmlParser = ArrayXMLParser(contentsOf: url, forItems: "point")
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
                Settings.current.lastUpdate.value = Date()
                Database.sharedDatabase.saveContext(Database.sharedDatabase.backgroundManagedObjectContext)
                print("Complete savings")
            },
              value: { value in
                if let pointDict = value as? [String:AnyObject] {
                    
                    Database.sharedDatabase.backgroundManagedObjectContext.performAndWait {
                        let _ = Point.point(fromDictionary: pointDict, inContext: Database.sharedDatabase.backgroundManagedObjectContext)
                        
                        Database.sharedDatabase.backgroundManagedObjectContext.delayedSaveOrRollback(completion: { (saved) in
                            if saved {
                                Database.sharedDatabase.backgroundManagedObjectContext.reset()
                            }
                        })
                    }
                }
        }).start()
    }
}
