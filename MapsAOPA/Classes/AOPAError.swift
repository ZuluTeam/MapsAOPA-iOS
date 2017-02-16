//
//  AOPAError.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/15/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation

public enum AOPAError: Error {
    
    case Unknown /// Unknown or not supported error.
    case NotConnectedToInternet /// Not connected to the internet.
    case InternationalRoamingOff /// International data roaming turned off.
    case NotReachedServer /// Cannot reach the server.
    case ConnectionLost /// Connection is lost.
    case IncorrectDataReturned /// Incorrect data returned from the server.
    case FileNotFound /// File not found
    
    init(_ error : NSError?) {
        guard let error = error else {
            self = .Unknown
            return
        }
        switch error.domain {
        case NSURLErrorDomain:
            self = AOPAError.networkError(error)
        case XMLParser.errorDomain:
            self = AOPAError.dataError(error)
        default: self = .Unknown
        }
    }
    
    public var description: String {
        let text: String
        switch self {
        case .Unknown:
            text = "Error_Unknown".localized()
        case .NotConnectedToInternet:
            text = "Error_NotConnectedToInternet".localized()
        case .InternationalRoamingOff:
            text = "Error_InternationalRoamingOff".localized()
        case .NotReachedServer:
            text = "Error_NotReachedServer".localized()
        case .ConnectionLost:
            text = "Error_ConnectionLost".localized()
        case .IncorrectDataReturned:
            text = "Error_IncorrectDataReturned".localized()
        case .FileNotFound:
            text = "Error_FileNotFound".localized()
        }
        return text
    }
}
