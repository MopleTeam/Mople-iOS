//
//  AppCalendar.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation

final class DateManager {
    
    static let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }()
    
    static let fullDateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "YYYY.MM.dd E HH시 mm분"
        return dateFormatter
    }()
    
    static let simpleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
    private init() { }
}

// MARK: - 계산
extension DateManager {
    static func convertDateComponents(_ date: Date) -> DateComponents {
        return calendar.dateComponents([.year, .month, .day], from: date)
    }
    
    static func convertDate(_ dateComponents: DateComponents) -> Date? {
        return calendar.date(from: dateComponents)
    }
    
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .day)
    }
    
    static func isSameWeek(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .weekOfYear)
    }
    
    static func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .month)
    }
}

extension Date {
    public func getComponents() -> DateComponents {
        return DateManager.convertDateComponents(self)
    }
}

extension DateComponents {
    public func getDate() -> Date? {
        return DateManager.convertDate(self)
    }
}
