//
//  AOPALoader.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/15/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveSwift

public final class AOPALoader {
    private let network : Network
    
    init(network: Network) {
        self.network = network
    }
    
    func loadAirfields() -> SignalProducer<URL, AOPAError> {
//#if DEBUG
//        return SignalProducer { observer, _ in
//            if let url = Bundle.main.url(forResource: "aopa-points-export", withExtension: "xml") {
//                observer.send(value: url)
//                observer.sendCompleted()
//            } else {
//                observer.send(error: AOPAError.FileNotFound)
//            }
//        }
//#else
        return self.network
            .downloadData(AOPANetwork.dataURL, parameters: nil, destination: "aopa-points")
            .mapError({ AOPAError($0) })
//#endif
    }
    
    func loadImage(_ imagePath: String) -> SignalProducer<UIImage, AOPAError> {
        return self.network
            .downloadImage(AOPANetwork.imageURL(for: imagePath))
            .mapError({ AOPAError($0) })
    }
}
