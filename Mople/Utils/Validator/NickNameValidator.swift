//
//  Validator.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import Foundation

struct Validator {
    
    static func checkNickname(_ name: String?) -> Bool {
        guard let name = name else { return false }
              
        return !name.contains(where: { $0.isWhitespace }) &&
              name.checkValidator() &&
              (2...15).contains(name.count)
    }
}



