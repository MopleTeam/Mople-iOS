//
//  DataRequestError.swift
//  Data
//
//  비즈니스 레벨 네트워크 에러 — Repository에서 throw
//

import Foundation
import Domain

public enum DataRequestError: Error, ServerErrorIdentifiable {

    /// ServerErrorIdentifiable 채택 — Domain에서 타입 참조 없이 에러 분류 가능
    public var isNotFound: Bool { self == .noResponse }

    case networkUnavailable
    case serverUnavailable
    case unknown
    case expiredToken
    case noResponse
    case handled

    public var info: String? {
        switch self {
        case .networkUnavailable:
            "네트워크 연결을 확인해주세요."
        case .serverUnavailable:
            "서버와 소통이 원활하지 않습니다."
        case .unknown:
            "요청에 실패했습니다.\n잠시 후 다시 시도해주세요."
        case .expiredToken:
            "로그인이 만료되었어요"
        default:
            nil
        }
    }

    public var subInfo: String? {
        switch self {
        case .expiredToken:
            "서비스 이용을 위해 다시 로그인해주세요"
        case .serverUnavailable:
            "현재 서버와의 연결이 원활하지 않습니다.\n잠시 후 다시 시도해 주세요."
        default:
            nil
        }
    }

    public static func resolveNoResponseError(err: DataRequestError,
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

    public static func isHandledError(err: Error) -> Bool {
        guard let requestErr = err as? Self else { return false }
        return requestErr == .handled
    }
}
