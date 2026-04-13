//
//  GroupTitleValidator.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation

public struct MeetTitleValidator {

    public enum result {
        case success, empty, countUnder, countOver
    }

    public static func validator(_ text: String?) -> result {
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



