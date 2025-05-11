//
//  DataRequsetError.swift
//  Mople
//
//  Created by CatSlave on 3/27/25.
//

import Foundation

enum DataRequestError: Error {
    
    case networkUnavailable
    case serverUnavailable
    case unknown
    case expiredToken
    case noResponse
    case handled
    
    var info: String? {
        switch self {
        case .networkUnavailable:
            L10n.Error.network
        case .serverUnavailable:
            L10n.Error.Server.info
        case .unknown:
            L10n.Error.default
        case .expiredToken:
            L10n.Error.ExpriedToken.info
        default:
            nil
        }
    }
    
    var subInfo: String? {
        switch self {
        case .expiredToken:
            L10n.Error.ExpriedToken.subinfo
        case .serverUnavailable:
            L10n.Error.Server.subinfo
        default:
            nil
        }
    }
    
    static func resolveNoResponseError(err: DataRequestError,
                                       responseType: ResponseType) -> ResponseError? {
        guard .noResponse == err else { return nil }
        
        switch responseType {
        case let .meet(id):
            return ResponseError.noResponse(.meet(id: id))
        case let .plan(id):
            return ResponseError.noResponse(.plan(id: id))
        case let .review(id):
            return ResponseError.noResponse(.review(id: id))
        }
    }
    
    static func isHandledError(err: Error) -> Bool {
        guard let requestErr = err as? Self else { return false }
        return requestErr == .handled
    }
}
