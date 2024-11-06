//
//  Date+Convert.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

extension Date {
    func getComponents() -> DateComponents {
        return DateManager.calendar.dateComponents([.year, .month, .day], from: self)
    }
}

extension Date {
    func convertString(format: DateStringFormat) -> String {
        switch format {
        case .full:
            DateManager.fullDateTimeFormatter.string(from: self)
        case .simple:
            DateManager.simpleDateFormatter.string(from: self)
        }
    }
}

