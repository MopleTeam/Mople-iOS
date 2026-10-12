//
//  DateTransitionError.swift
//  Data
//
//  자정 전환 에러
//

import Foundation

public enum DateTransitionError: Error {
    case midnightReset

    public var info: String {
        switch self {
        case .midnightReset:
            "자정을 지나 데이터가 업데이트됐어요!"
        }
    }

    public var subInfo: String? {
        switch self {
        case .midnightReset:
            "일정이 마감됐어요.\n후기에서 확인해보세요."
        }
    }
}
