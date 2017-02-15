//
//  MapViewModeling.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/15/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public protocol MapViewModeling {
    var isLoading : Property<Bool> { get }
    var progress : Property<Float> { get }
    
    func loadAirfields()
    func fetchAirfields()
}
