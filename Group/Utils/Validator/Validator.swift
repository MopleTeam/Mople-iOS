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
        case countUnder
        case countOver
        case strange
        
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
    
    #warning("switch 패턴 매칭 활용하기")
    static func checkNickname(name: String?) -> result {
        guard let name = name, !name.isEmpty else {
            return .empty
        }
        
        switch name {
        case _ where name.contains(where: { $0.isWhitespace }) && !name.checkValidator():
            return .strange
        case _ where name.count <= 1:
            return .countUnder
        case _ where name.count > 10:
            return .countOver
        default:
            return .success
        }
    }
}

extension String {
    func checkValidator() -> Bool {
        let inputRegEx = "^[가-힣a-zA-Z0-9]+$"
        let inputPred = NSPredicate(format: "SELF MATCHES %@", inputRegEx)
        
        return inputPred.evaluate(with: self)
    }
}

