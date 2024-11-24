//
//  Date+Convert.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

// MARK: - 데이트 -> 컴포넌트
enum DateStringFormat {
    case full
    case simple
}

extension Date {
    func getHours() -> Int {
        return DateManager.calendar.dateComponents([.hour], from: self).hour ?? 0
    }
    
    func getComponents() -> DateComponents {
        return DateManager.calendar.dateComponents([.year, .month, .day], from: self)
    }
}

extension Optional where Wrapped == Date {
    func convertString(format: DateStringFormat) -> String? {
        guard let self else { return nil }
        switch format {
        case .full:
            return DateManager.detailDateFormatter.string(from: self)
        case .simple:
            return DateManager.simpleDateFormatter.string(from: self)
        }
    }
}
