//
//  DataLoader.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import AFNetworking
import ReactiveSwift

class DataLoader
{
    fileprivate static let serverAddress : String = "http://maps.aopa.ru"
    fileprivate static let dataPath : String = "/export/exportFormRequest/?exportType=standart&exportAll%5B%5D=airport&exportAll%5B%5D=vert&exportFormat=xml"
    fileprivate static let imagesPath : String = "/static/pointImages/"
    
    static var apiKey : String? {
        get {
            return Config.networkConfig[AppKeys.ApiKey.rawValue] as? String ?? UserDefaults.standard.string(forKey: AppKeys.ApiKey.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppKeys.ApiKey.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static let sharedLoader : DataLoader = DataLoader()
    
    fileprivate lazy var session = URLSession(configuration: URLSessionConfiguration.default)
    
    fileprivate init() { }
    
    func signalForAirfieldsData() -> SignalProducer<URL, NSError>
    {
        return SignalProducer({
            observer, disposable in
            if let apiKey = DataLoader.apiKey, apiKey.length > 0
            {
                let url = URL(string: "\(DataLoader.serverAddress)\(DataLoader.dataPath)&api_key=\(apiKey)")!
                self.session.downloadTask(with: URLRequest(url: url), completionHandler: { (fileURL, response, error) in
                    if let error = error as? NSError
                    {
                        observer.send(error: error)
                    }
                    else if let fileURL = fileURL
                    {
                        observer.send(value: fileURL)
                        observer.sendCompleted()
                    }
                    else
                    {
                        observer.send(error: Error.fileNotFound.error())
                    }
                }).resume()
            }
            else
            {
                observer.send(error: Error.apiKeyRequired.error())
            }
        })
    }
}
