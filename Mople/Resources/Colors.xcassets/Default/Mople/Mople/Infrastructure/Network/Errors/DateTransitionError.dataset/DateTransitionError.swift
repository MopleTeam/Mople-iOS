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
            L10n.Error.Midnight.info
        }
    }
    
    var subInfo: String? {
        switch self {
        case .midnightReset:
            L10n.Error.Midnight.subinfo
        }
    }
}
