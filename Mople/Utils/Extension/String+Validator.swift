//
//  String+Validator.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation

extension String {
    func checkValidator() -> Bool {
        let inputRegEx = "^[가-힣a-zA-Z0-9]+$"
        let inputPred = NSPredicate(format: "SELF MATCHES %@", inputRegEx)
        
        return inputPred.evaluate(with: self)
    }
}
