//
//  AppCalendar.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation

final class DateManager {
    
    static let today = Date()
    
    static let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }()
    
    static let isoFormatter: ISO8601DateFormatter = {
        let format = ISO8601DateFormatter()
        format.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return format
    }()
    
    static let detailDateFormatter: DateFormatter = {
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

extension DateManager {
    static func getMinimumDate() -> Date {
        var components = today.getComponents()
        components.month = 1
        components.day = 1
        let firstDate = components.getDate() ?? Date()
        return calendar.date(byAdding: .year, value: -10, to: firstDate) ?? Date()
    }
    
    static func getMaximumDate() -> Date {
        var components = today.getComponents()
        components.month = 12
        components.day = 31
        let firstDate = components.getDate() ?? Date()
        return calendar.date(byAdding: .year, value: 10, to: firstDate) ?? Date()
    }
    
}

// MARK: - 비교
extension DateManager {
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .day)
    }
    
    static func isSameWeek(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .weekOfYear)
    }
    
    static func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .month)
    }
    
    static func startOfDay(_ date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }

    static func isNextMonth(_ date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date) ?? Date()
    }
    
    static func isPreviousMonth(_ date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date) ?? Date()
    }
    
    #warning("사용하지 않음, 정리용")
    // 두 날짜를 미래, 과거, 같음으로 비교 가능
    static func checkDateStatus(_ date: Date) -> ComparisonResult {
        return  calendar.compare(date, to: .now, toGranularity: .day)
    }
    
    static func numberOfDaysBetween(_ date: Date) -> Int {
        let now = startOfDay(.now)
        let scheduleDate = startOfDay(date)
        let result = calendar.dateComponents([.day], from: now, to: scheduleDate)
        return result.day ?? 0
    }
}

