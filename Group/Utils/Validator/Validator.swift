//
//  Validator.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import Foundation

struct Validator {
    
    enum result {
        case success
        case empty
        case countOver
        case strange
        
        var info: String {
            switch self {
            case .success:
                "사용 가능한 닉네임입니다."
            case .empty:
                "닉네임을 입력해주세요."
            case .countOver:
                "닉네임은 10글자 이하로 입력해 주세요."
            case .strange:
                "특수문자는 사용할 수 없습니다.\n한글, 영문, 숫자만 입력해 주세요."
            }
        }
    }
    
    static func checkNickname(name: String?) -> result {
        guard let name = name else {
            return .empty
        }
        
        let trimmedInput = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let inputRegEx = "^[가-힣a-zA-Z0-9]+$"
        let inputPred = NSPredicate(format: "SELF MATCHES %@", inputRegEx)
        
        guard name.count > 0 else {
            return .empty
        }
        
        guard name.count <= 10 else {
            return .countOver
        }
        
        guard inputPred.evaluate(with: trimmedInput) else {
            return .strange
        }
        
        return .success
    }
    
}

