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

    
    func downloadData(_ url: String, parameters: [String: Any]?, destination: String) -> SignalProducer<URL, NSError> {
        return SignalProducer { observer, disposable in
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(destination)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let request = Alamofire.download(url, method: .get, parameters: parameters, to: destination).response { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let destination = response.destinationURL {
                    observer.send(value: destination)
                    observer.sendCompleted()
                } else {
                    if let error = response.error as? NSError {
                        observer.send(error: error)
                    }
                }
            }
            disposable.add({
                request.cancel()
            })
        }
    }
    
    func downloadImage(_ url: String) -> SignalProducer<UIImage, NSError> {
        return SignalProducer { [weak self] observer, disposable in
            if let image = self?.imageCache.image(withIdentifier: url) {
                observer.send(value: image)
                observer.sendCompleted()
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                let request = Alamofire.request(url).responseImage { [weak self] response in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let image = response.result.value {
                        self?.imageCache.add(image, withIdentifier: url)
                        observer.send(value: image)
                        observer.sendCompleted()
                    } else {
                        if let error = response.error as? NSError {
                            observer.send(error: error)
                        }
                    }
                }
                disposable.add({
                    request.cancel()
                })
            }
        }
    }
}
