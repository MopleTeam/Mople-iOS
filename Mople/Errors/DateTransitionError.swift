//
//  DateTransitionError.swift
//  Mople
//
//  Created by CatSlave on 3/27/25.
//

import Foundation

enum DateTransitionError: Error {
    case midnightReset
    
    var info: String {
        switch self {
        case .midnightReset:
            "자정을 지나 데이터가 업데이트됐어요!"
        }
    }
    
    var subInfo: String? {
        switch self {
        case .midnightReset:
            "일정이 마감됐어요.\n후기에서 확인해보세요."
        }
    }
}
