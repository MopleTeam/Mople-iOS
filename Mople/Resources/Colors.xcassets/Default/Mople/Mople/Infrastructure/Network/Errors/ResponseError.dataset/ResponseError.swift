//
//  PlanError.swift
//  Mople
//
//  Created by CatSlave on 3/27/25.
//

import Foundation

enum ResponseType {
    case meet(id: Int)
    case plan(id: Int)
    case review(id: Int)
}

enum ResponseError: Error {

    case noResponse(ResponseType)
    
    var info: String {
        switch self {
        case let .noResponse(responseType):
            handleNoResponseInfo(err: responseType)
        }
    }
    
    private func handleNoResponseInfo(err: ResponseType) -> String {
        switch err {
        case .meet:
            L10n.Error.NoResponse.meet
        case .plan:
            L10n.Error.NoResponse.plan
        case .review:
            L10n.Error.NoResponse.review
        }
    }
}

