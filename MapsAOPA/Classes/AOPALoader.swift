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
    
    func loadAirfields() -> SignalProducer<URL, NetworkError> {
        return self.network.downloadData(AOPANetwork.dataURL, parameters: AOPANetwork.exportParameters, destination: "aopa-points")
    }
    
    func loadImage(_ imagePath: String) -> SignalProducer<UIImage, NetworkError> {
        return self.network.downloadImage(AOPANetwork.imageURL(for: imagePath))
    }
}
