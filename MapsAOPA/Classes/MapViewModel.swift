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
    
    
    
    init() {}
    
    func loadSignal() -> SignalProducer<Void, NSError>
    {
        let timeInterval = Date().timeIntervalSince(Settings.lastUpdate as Date)
//        if  Config.weekTimeInterval < timeInterval
//        {
//            return DataLoader.sharedLoader.signalForAirfieldsData()
//                .flatMap(.Latest, transform: { value -> SignalProducer<[String:AnyObject], NSError> in
//                    
//                    
//                        return self.elementsFromSignal(XMLParser(contentsOfURL: value)!.parserSignal()).on(next: {
//                            Point.point(fromDictionary: $0, inContext: Database.sharedDatabase.backgroundManagedObjectContext)
//                            }, completed: {
//                                Config.lastUpdate = NSDate()
//                                Database.sharedDatabase.saveContext(Database.sharedDatabase.backgroundManagedObjectContext)
//                        }).startOn(QueueScheduler(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))).observeOn(UIScheduler())
//                })
//                .map({ _ in  })
//        }
//        else
//        {
            return SignalProducer { observer, disposable in observer.sendCompleted() }
//        }
    }
    
//    fileprivate func elementsFromSignal(_ signal: SignalProducer<(element: String, state: XMLParseState, characters: String?), NSError>) -> SignalProducer<[String:AnyObject], NSError>
//    {
//        return SignalProducer {
//            observer, disposable in
    
//            var stack : NSMutableArray = NSMutableArray()
//            let arrayElements = Set(arrayLiteral: "vpp", "contact", "freq", "fuel")
            
//            signal.filter({ $0.element != "points" }).on(starting: { (element, state, characters) in
//                switch state
//                {
//                case .Start:
//                    let elementObject : AnyObject
//                    if arrayElements.contains(element)
//                    {
//                        elementObject = NSMutableArray()
//                    }
//                    else
//                    {
//                        elementObject = NSMutableDictionary()
//                    }
//                    
//                    if let parent = stack.lastObject
//                    {
//                        if parent is NSMutableDictionary
//                        {
//                            (parent as! NSMutableDictionary)[element] = elementObject
//                        }
//                        else if parent is NSMutableArray
//                        {
//                            (parent as! NSMutableArray).addObject(elementObject)
//                        }
//                    }
//                    stack.addObject(elementObject)
//                case .End where element == "point":
//                    if let point = stack.lastObject as? [String:AnyObject]
//                    {
//                        observer.sendNext(point)
//                    }
//                    stack = NSMutableArray()
//                case .End:
//                    stack.removeLastObject()
//                    if let parent = stack.lastObject as? NSMutableDictionary
//                    {
//                        if let text = characters
//                        {
//                            parent[element] = text
//                        }
//                        else if !arrayElements.contains(element)
//                        {
//                            parent.removeObjectForKey(element)
//                        }
//                    }
//                }
//            },
//                                                         failed: { observer.sendFailed($0) },
//                                                         completed: { observer.sendCompleted() }).start()
//        }
//    }
}
