//
//  Validator.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import Foundation

struct Validator {
    
    static func checkValidator(with name: String) -> Bool {
        let inputRegEx = "^[가-힣a-zA-Z0-9]+$"
        let inputPred = NSPredicate(format: "SELF MATCHES %@", inputRegEx)
        
        return inputPred.evaluate(with: name)
    }
    
    static func checkNickname(_ name: String?) -> Bool {
        guard let name = name else { return false }
        
        return !name.contains(where: { $0.isWhitespace }) &&
        checkValidator(with: name) &&
        (2...15).contains(name.count)
    }
}



