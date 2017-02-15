//
//  DataLoader.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import AlamofireImage

class Network {
    fileprivate  var imageCache = AutoPurgingImageCache()

    
    func downloadData(_ url: String, parameters: [String: Any]?, destination: String) -> SignalProducer<URL, NetworkError> {
        return SignalProducer { observer, disposable in
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(destination)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download(url, method: .get, parameters: parameters, to: destination).response { response in
                if let destination = response.destinationURL {
                    observer.send(value: destination)
                    observer.sendCompleted()
                } else {
                    observer.send(error: NetworkError(error: response.error as? NSError))
                }
            }
        }
    }
    
    func downloadImage(_ url: String) -> SignalProducer<UIImage, NetworkError> {
        return SignalProducer { [weak self] observer, disposable in
            if let image = self?.imageCache.image(withIdentifier: url) {
                observer.send(value: image)
                observer.sendCompleted()
            } else {
                Alamofire.request(url).responseImage { [weak self] response in
                    if let image = response.result.value {
                        self?.imageCache.add(image, withIdentifier: url)
                        observer.send(value: image)
                        observer.sendCompleted()
                    } else {
                        observer.send(error: NetworkError(error: response.error as? NSError))
                    }
                }
            }
        }
    }
}
