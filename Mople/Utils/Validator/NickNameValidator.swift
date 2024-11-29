//
//  Validator.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import Foundation

struct NickNameValidator {
    
    enum ValidatorError: Error {
        case success, empty, countUnder, countOver, strange
        
        var info: String {
            switch self {
            case .success:
                "사용 가능한 닉네임입니다."
            case .empty:
                "닉네임을 입력해주세요."
            case .countUnder:
                "닉네임은 2글자 이상으로 입력해 주세요."
            case .countOver:
                "닉네임은 10글자 이하로 입력해 주세요."
            case .strange:
                "특수문자는 사용할 수 없습니다.\n한글, 영문, 숫자만 입력해 주세요."
            }
        }
    }
    
    static func checkNickname(_ name: String?) throws {
        guard let name = name, !name.isEmpty else {
            throw ValidatorError.empty
        }
        switch name {
        case _ where name.contains(where: { $0.isWhitespace }) || !name.checkValidator():
            throw ValidatorError.strange
        case _ where name.count < 2:
            throw ValidatorError.countUnder
        case _ where name.count > 15:
            throw ValidatorError.countOver
        default:
            return
        }
    }
}



