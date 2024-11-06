//
//  DateComponents.swift
//  Group
//
//  Created by CatSlave on 9/25/24.
//

import Foundation

extension DateComponents {
    func getDate() -> Date? {
        return DateManager.calendar.date(from: self)
    }
}

