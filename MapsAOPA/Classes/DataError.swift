//
//  DataError.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/15/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation

public enum DataError: Error {
    /// Unknown or not supported error.
    case Unknown
    
    /// File not found
    case FileNotFound
    
    /// Incorrect data returned from the server.
    case IncorrectDataReturned
    
    internal init(error: NSError?) {
        if let error = error, error.domain == XMLParser.errorDomain, let errorCode = XMLParser.ErrorCode(rawValue: error.code) {
            switch errorCode {
                
            case XMLParser.ErrorCode.documentStartError,
                 XMLParser.ErrorCode.emptyDocumentError,
                 XMLParser.ErrorCode.prematureDocumentEndError,
                 XMLParser.ErrorCode.invalidHexCharacterRefError,
                 XMLParser.ErrorCode.invalidDecimalCharacterRefError,
                 XMLParser.ErrorCode.invalidCharacterRefError,
                 XMLParser.ErrorCode.invalidCharacterError,
                 XMLParser.ErrorCode.characterRefAtEOFError,
                 XMLParser.ErrorCode.characterRefInPrologError,
                 XMLParser.ErrorCode.characterRefInEpilogError,
                 XMLParser.ErrorCode.characterRefInDTDError,
                 XMLParser.ErrorCode.entityRefAtEOFError,
                 XMLParser.ErrorCode.entityRefInPrologError,
                 XMLParser.ErrorCode.entityRefInEpilogError,
                 XMLParser.ErrorCode.entityRefInDTDError,
                 XMLParser.ErrorCode.parsedEntityRefAtEOFError,
                 XMLParser.ErrorCode.parsedEntityRefInPrologError,
                 XMLParser.ErrorCode.parsedEntityRefInEpilogError,
                 XMLParser.ErrorCode.parsedEntityRefInInternalSubsetError,
                 XMLParser.ErrorCode.entityReferenceWithoutNameError,
                 XMLParser.ErrorCode.entityReferenceMissingSemiError,
                 XMLParser.ErrorCode.parsedEntityRefNoNameError,
                 XMLParser.ErrorCode.parsedEntityRefMissingSemiError,
                 XMLParser.ErrorCode.undeclaredEntityError,
                 XMLParser.ErrorCode.unparsedEntityError,
                 XMLParser.ErrorCode.entityIsExternalError,
                 XMLParser.ErrorCode.entityIsParameterError,
                 XMLParser.ErrorCode.encodingNotSupportedError,
                 XMLParser.ErrorCode.stringNotStartedError,
                 XMLParser.ErrorCode.stringNotClosedError,
                 XMLParser.ErrorCode.namespaceDeclarationError,
                 XMLParser.ErrorCode.entityNotStartedError,
                 XMLParser.ErrorCode.entityNotFinishedError,
                 XMLParser.ErrorCode.lessThanSymbolInAttributeError,
                 XMLParser.ErrorCode.attributeNotStartedError,
                 XMLParser.ErrorCode.attributeNotFinishedError,
                 XMLParser.ErrorCode.attributeHasNoValueError,
                 XMLParser.ErrorCode.attributeRedefinedError,
                 XMLParser.ErrorCode.literalNotStartedError,
                 XMLParser.ErrorCode.literalNotFinishedError,
                 XMLParser.ErrorCode.commentNotFinishedError,
                 XMLParser.ErrorCode.processingInstructionNotStartedError,
                 XMLParser.ErrorCode.processingInstructionNotFinishedError,
                 XMLParser.ErrorCode.notationNotStartedError,
                 XMLParser.ErrorCode.notationNotFinishedError,
                 XMLParser.ErrorCode.attributeListNotStartedError,
                 XMLParser.ErrorCode.attributeListNotFinishedError,
                 XMLParser.ErrorCode.mixedContentDeclNotStartedError,
                 XMLParser.ErrorCode.mixedContentDeclNotFinishedError,
                 XMLParser.ErrorCode.elementContentDeclNotStartedError,
                 XMLParser.ErrorCode.elementContentDeclNotFinishedError,
                 XMLParser.ErrorCode.xmlDeclNotStartedError,
                 XMLParser.ErrorCode.xmlDeclNotFinishedError,
                 XMLParser.ErrorCode.conditionalSectionNotStartedError,
                 XMLParser.ErrorCode.conditionalSectionNotFinishedError,
                 XMLParser.ErrorCode.externalSubsetNotFinishedError,
                 XMLParser.ErrorCode.doctypeDeclNotFinishedError,
                 XMLParser.ErrorCode.misplacedCDATAEndStringError,
                 XMLParser.ErrorCode.cdataNotFinishedError,
                 XMLParser.ErrorCode.misplacedXMLDeclarationError,
                 XMLParser.ErrorCode.spaceRequiredError,
                 XMLParser.ErrorCode.separatorRequiredError,
                 XMLParser.ErrorCode.nmtokenRequiredError,
                 XMLParser.ErrorCode.nameRequiredError,
                 XMLParser.ErrorCode.pcdataRequiredError,
                 XMLParser.ErrorCode.uriRequiredError,
                 XMLParser.ErrorCode.publicIdentifierRequiredError,
                 XMLParser.ErrorCode.ltRequiredError,
                 XMLParser.ErrorCode.gtRequiredError,
                 XMLParser.ErrorCode.ltSlashRequiredError,
                 XMLParser.ErrorCode.equalExpectedError,
                 XMLParser.ErrorCode.tagNameMismatchError,
                 XMLParser.ErrorCode.unfinishedTagError,
                 XMLParser.ErrorCode.standaloneValueError,
                 XMLParser.ErrorCode.invalidEncodingNameError,
                 XMLParser.ErrorCode.commentContainsDoubleHyphenError,
                 XMLParser.ErrorCode.invalidEncodingError,
                 XMLParser.ErrorCode.externalStandaloneEntityError,
                 XMLParser.ErrorCode.invalidConditionalSectionError,
                 XMLParser.ErrorCode.entityValueRequiredError,
                 XMLParser.ErrorCode.notWellBalancedError,
                 XMLParser.ErrorCode.extraContentError,
                 XMLParser.ErrorCode.invalidCharacterInEntityError,
                 XMLParser.ErrorCode.parsedEntityRefInInternalError,
                 XMLParser.ErrorCode.entityRefLoopError,
                 XMLParser.ErrorCode.entityBoundaryError,
                 XMLParser.ErrorCode.invalidURIError,
                 XMLParser.ErrorCode.uriFragmentError,
                 XMLParser.ErrorCode.noDTDError,
                 XMLParser.ErrorCode.unknownEncodingError: self = .IncorrectDataReturned
            case XMLParser.ErrorCode.internalError,
                 XMLParser.ErrorCode.outOfMemoryError,
                 XMLParser.ErrorCode.delegateAbortedParseError: self = .Unknown
            }
        }
        else {
            self = .Unknown
        }
    }
    
    public var description: String {
        let text: String
        switch self {
        case .Unknown:
            text = "DataError_Unknown".localized()
        case .FileNotFound:
            text = "DataError_FileNotFound".localized()
        case .IncorrectDataReturned:
            text = "DataError_IncorrectData".localized()
        }
        return text
    }
}
