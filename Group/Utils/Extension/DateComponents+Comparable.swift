//
//  DateComponents.swift
//  Group
//
//  Created by CatSlave on 9/25/24.
//

import Foundation

extension DateComponents: @retroactive Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let calendar = DateManager.calendar
        
        guard let lhsDate = calendar.date(from: lhs),
              let rhsDate = calendar.date(from: rhs) else { return false }
        
        return lhsDate < rhsDate
    }
}
