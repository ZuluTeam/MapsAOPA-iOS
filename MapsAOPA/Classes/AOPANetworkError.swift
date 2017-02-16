//
//  AOPANetworkError.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/16/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation

extension AOPAError {
    
    static func networkError(_ error: NSError) -> AOPAError {
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorUnknown: return .Unknown
            case NSURLErrorCancelled: return .Unknown // Cancellation is not used in this project.
            case NSURLErrorBadURL: return .IncorrectDataReturned // Because it is caused by a bad URL returned in a JSON response from the server.
            case NSURLErrorTimedOut: return .NotReachedServer
            case NSURLErrorUnsupportedURL: return .IncorrectDataReturned
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost: return .NotReachedServer
            case NSURLErrorDataLengthExceedsMaximum: return .IncorrectDataReturned
            case NSURLErrorNetworkConnectionLost: return .ConnectionLost
            case NSURLErrorDNSLookupFailed: return .NotReachedServer
            case NSURLErrorHTTPTooManyRedirects: return .Unknown
            case NSURLErrorResourceUnavailable: return .IncorrectDataReturned
            case NSURLErrorNotConnectedToInternet: return .NotConnectedToInternet
            case NSURLErrorRedirectToNonExistentLocation, NSURLErrorBadServerResponse: return .IncorrectDataReturned
            case NSURLErrorUserCancelledAuthentication, NSURLErrorUserAuthenticationRequired: return .Unknown
            case NSURLErrorZeroByteResource, NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData: return .IncorrectDataReturned
            case NSURLErrorCannotParseResponse: return .IncorrectDataReturned
            case NSURLErrorInternationalRoamingOff: return .InternationalRoamingOff
            case NSURLErrorCallIsActive, NSURLErrorDataNotAllowed, NSURLErrorRequestBodyStreamExhausted: return .Unknown
            case NSURLErrorFileDoesNotExist, NSURLErrorFileIsDirectory: return .IncorrectDataReturned
            case NSURLErrorNoPermissionsToReadFile,
                 NSURLErrorSecureConnectionFailed,
                 NSURLErrorServerCertificateHasBadDate,
                 NSURLErrorServerCertificateUntrusted,
                 NSURLErrorServerCertificateHasUnknownRoot,
                 NSURLErrorServerCertificateNotYetValid,
                 NSURLErrorClientCertificateRejected,
                 NSURLErrorClientCertificateRequired,
                 NSURLErrorCannotLoadFromNetwork,
                 NSURLErrorCannotCreateFile,
                 NSURLErrorCannotOpenFile,
                 NSURLErrorCannotCloseFile,
                 NSURLErrorCannotWriteToFile,
                 NSURLErrorCannotRemoveFile,
                 NSURLErrorCannotMoveFile,
                 NSURLErrorDownloadDecodingFailedMidStream,
                 NSURLErrorDownloadDecodingFailedToComplete: return .Unknown
            default: return .Unknown
            }
        }
        return .Unknown
    }
}
