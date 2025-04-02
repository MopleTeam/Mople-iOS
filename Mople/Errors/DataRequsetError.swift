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
            "네트워크 연결을 확인해주세요."
        case .serverUnavailable:
            "일시적인 오류 발생"
        case .unknown:
            "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해주세요."
        case .expiredToken:
            "로그인이 만료되었어요"
        default:
            nil
        }
    }
    
    var subInfo: String? {
        switch self {
        case .expiredToken:
            "서비스 이용을 위해 다시 로그인해주세요"
        case .serverUnavailable:
            "현재 서버와의 연결이 원활하지 않습니다.\n잠시 후 다시 시도해 주세요."
        default:
            nil
        }
    }
    
    static func resolveNoResponseError(err: Error,
                                       responseType: ResponseType) -> Error {
        guard let requestError = err as? DataRequestError,
              requestError == .noResponse else { return err }
        
        switch responseType {
        case let .meet(id):
            return ResponseError.noResponse(.meet(id: id))
        case let .plan(id):
            return ResponseError.noResponse(.plan(id: id))
        case let .review(id):
            return ResponseError.noResponse(.review(id: id))
        }
    }
}
