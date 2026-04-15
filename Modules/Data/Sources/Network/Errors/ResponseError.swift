//
//  ResponseError.swift
//  Data
//
//  리소스(모임/일정/후기) 없음 에러
//

import Foundation

public enum ResponseType {
    case meet(id: Int)
    case plan(id: Int)
    case review(id: Int)
}

public enum ResponseError: Error {
    case noResponse(ResponseType)

    public var info: String {
        switch self {
        case let .noResponse(responseType):
            handleNoResponseInfo(err: responseType)
        }
    }

    private func handleNoResponseInfo(err: ResponseType) -> String {
        switch err {
        case .meet:
            "모임을 찾을 수 없어요."
        case .plan:
            "일정을 찾을 수 없어요."
        case .review:
            "후기를 찾을 수 없어요."
        }
    }
}
