//
//  NSXMLParser+ReactiveCocoa.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/16/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveSwift

enum XMLParseState
{
    case start, end
}
/*
extension XMLParser
{
    fileprivate class XMLParserDelegate : NSObject, Foundation.XMLParserDelegate, Disposable
    {
        /// Whether this disposable has been disposed already.
        public var isDisposed: Bool

        var disposed : Bool = false
        var observer : Observer<(element: String, state: XMLParseState, characters: String?), NSError>
        var element : String?
        var characters : String?
        
        init(observer: Observer<(element: String, state: XMLParseState, characters: String?), NSError>)
        {
            self.observer = observer
        }
        
        func dispose() {
            observer.sendCompleted()
        }
        
        // MARK : NSXMLParserDelegate
        
        @objc fileprivate func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
            self.element = elementName
            self.characters = nil
            self.observer.sendNext((elementName, .Start, self.characters))
        }
        
        @objc fileprivate func parser(_ parser: XMLParser, foundCharacters string: String) {
            if self.characters == nil
            {
                self.characters = ""
            }
            self.characters?.append(string)
        }
        
        @objc fileprivate func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            self.observer.sendNext((elementName, .End, self.characters))
            if self.element == elementName
            {
                self.characters = nil
            }
        }
        
        @objc fileprivate func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            self.observer.sendFailed(parseError)
        }
        
        @objc fileprivate func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
            self.observer.sendFailed(validationError)
        }
        
        @objc fileprivate func parserDidEndDocument(_ parser: XMLParser) {
            self.observer.sendCompleted()
        }
    }
    
    func parserSignal() -> SignalProducer<(element: String, state: XMLParseState, characters: String?), NSError>
    {
        return SignalProducer {
            observer, disposable in
            
            let delegate = XMLParserDelegate(observer: observer)
            self.delegate = delegate
            self.parse()
            disposable.addDisposable(delegate)
        }
    }
}
*/
