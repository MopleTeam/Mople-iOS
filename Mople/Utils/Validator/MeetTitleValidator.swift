//
//  GroupTitleValidator.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation

struct MeetTitleValidator {
    
    enum result {
        case success, empty, countUnder, countOver
        
        var info: String {
            switch self {
            case .success:
                ""
            case .empty:
                "모임 이름을 입력해주세요."
            case .countUnder:
                "모임 이름은 2글자 이상으로 입력해 주세요."
            case .countOver:
                "모임 이름은 30글자 이하로 입력해 주세요."
            }
        }
    }
    
    static func validator(_ text: String?) -> result {
        guard let text = text, !text.isEmpty else {
            return .empty
        }
        switch text {
        case _ where text.count < 2:
            return .countUnder
        case _ where text.count > 30:
            return .countOver
        default:
            return .success
        }
    }
}



