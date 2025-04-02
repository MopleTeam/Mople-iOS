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
            "해당 일정은 후기로 확인해보세요."
        }
    }
}
