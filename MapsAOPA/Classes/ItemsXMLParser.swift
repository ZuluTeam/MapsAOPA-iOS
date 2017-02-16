//
//  ItemsXMLParser.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/14/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveSwift

class ItemsXMLParser : NSObject, XMLParserDelegate {
    
    private var xmlParser : XMLParser!
    private var itemKey : String!
    private var stack = [(key: String, value: String?, nodes: Any?)]()
    
    private weak var observer : Observer<Any, NSError>?
    private weak var disposable : Disposable?
    
    private override init() { super.init() }
    
    convenience init?(contentsOf url: URL, forItems itemKey: String) {
        self.init()
        self.itemKey = itemKey
        self.xmlParser = XMLParser(contentsOf: url)
        self.xmlParser.delegate = self
        guard let _ = xmlParser else {
            return nil
        }
    }
    
    func parse() -> SignalProducer<Any, NSError> {
        self.abortParsing()
        return SignalProducer { [weak self] observer, disposable in
            self?.observer = observer
            self?.disposable = disposable
            DispatchQueue.global().async {
                self?.xmlParser.parse()
            }
            disposable.add({ [weak self] in self?.abortParsing() })
        }
    }
    
    func abortParsing() {
        self.xmlParser.abortParsing()
        self.observer = nil
        self.disposable = nil
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.observer?.send(error: parseError as NSError)
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.observer?.sendCompleted()
        self.observer = nil
        self.disposable = nil
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if itemKey == elementName || !stack.isEmpty {
            stack.append((elementName, nil, nil))
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !stack.isEmpty {
            var last = stack.removeLast()
            last.value = (last.value ?? "").appending(string)
            stack.append(last)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if itemKey == elementName && stack.count == 1 {
            if let nodes = self.stack.last?.nodes {
                self.observer?.send(value: nodes)
            } else {
                self.observer?.sendCompleted()
            }
            stack.removeAll()
        } else if stack.count > 1 {
            let last = stack.removeLast()
            var container = stack.removeLast()
            var nodes = container.nodes
            let value = last.value ?? last.nodes
            if nil == nodes && nil != value {
                nodes = [ last.key : value! ]
                container.nodes = nodes
            } else if var nodesDict = nodes as? Dictionary<String, Any>, nil != value {
                if nil == nodesDict[last.key] {
                    nodesDict[last.key] = value!
                    container.nodes = nodesDict
                } else {
                    var nodes = [nodesDict]
                    nodes.append([ last.key : value! ])
                    container.nodes = nodes
                }
            } else if var nodesArray = nodes as? Array<Dictionary<String, Any>>, nil != value {
                nodesArray.append([ last.key : value! ])
                container.nodes = nodesArray
            }
            
            stack.append(container)
        } else {
            self.observer?.sendCompleted()
        }
    }
}
