//
//  Error.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/15/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import Foundation

enum AOPAError : Int
{
    static let domain = "com.example.MapsAOPA"
    
    case noError = 0
    case apiKeyRequired
    case fileNotFound
    case dataError
    
    func error() -> Foundation.NSError
    {
        return NSError(domain: AOPAError.domain, code: self.rawValue, userInfo: nil)
    }
}
