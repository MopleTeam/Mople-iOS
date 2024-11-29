//
//  GroupTitleValidator.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation

struct GroupTitleValidator {
    
    enum result {
        case success, empty, countUnder, countOver, strange
        
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
            case .strange:
                "특수문자는 사용할 수 없습니다.\n한글, 영문, 숫자만 입력해 주세요."
            }
        }
    }
    
    static func validator(_ text: String?) -> result {
        guard let text = text, !text.isEmpty else {
            return .empty
        }
        switch text {
        case _ where text.contains(where: { $0.isWhitespace }) || !text.checkValidator():
            return .strange
        case _ where text.count < 2:
            return .countUnder
        case _ where text.count > 30:
            return .countOver
        default:
            return .success
        }
    }
}



