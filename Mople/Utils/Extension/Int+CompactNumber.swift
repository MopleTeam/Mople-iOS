//
//  Int+CompactNumber.swift
//  Mople
//
//  Created by CatSlave on 7/23/25.
//

import Foundation

extension Int {
    func formatCompactNumber() -> String {
        switch self {
        case 1001...:
            return "1000+"
        case 101...:
            return "100+"
        default:
            return "\(self)"
        }
    }
}
