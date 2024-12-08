//
//  AppCalendar.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation

enum DateStringFormat {
    case full
    case simple
}

final class DateManager {
    
    static let today = Date()
    static var todayComponents: DateComponents {
       self.toDateComponents(today)
    }
    
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
    
    /// 앱에서 표시할 최소 날짜 Date
    static func getMinimumDate() -> Date {
        var components = self.todayComponents
        components.month = 1
        components.day = 1
        let firstDate = self.toDate(components) ?? Date()
        return calendar.date(byAdding: .year, value: -10, to: firstDate) ?? Date()
    }

    /// 앱에서 표시할 최대 날짜
    static func getMaximumDate() -> Date {
        var components = self.todayComponents
        components.month = 12
        components.day = 31
        let lastDate = self.toDate(components) ?? Date()
        return calendar.date(byAdding: .year, value: 10, to: lastDate) ?? Date()
    }
    
    /// 현재 달의 최대 일수
    static func getDaysCountInCurrentMonth(on dateComponents: DateComponents) -> Int {
        var calculateDate = dateComponents
        calculateDate.day = 1
        
        guard let date = toDate(calculateDate),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 28
        }
        return range.count
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
    
    static func numberOfDaysBetween(_ date: Date) -> Int {
        let scheduleDate = startOfDay(date)
        let result = calendar.dateComponents([.day], from: today, to: scheduleDate)
        return result.day ?? 0
    }
    
    static func numberOfMonthBetween(_ date: Date) -> Int {
        let todayYear = calendar.component(.year, from: today)
        let todayMonth = calendar.component(.month, from: today)
        
        let targetYear = calendar.component(.year, from: date)
        let targetMonth = calendar.component(.month, from: date)
        
        return (targetMonth - todayMonth) + (targetYear - todayYear) * 12
    }
}

// MARK: - 전환
extension DateManager {
    static func toDateComponents(_ date: Date) -> DateComponents {
        return DateManager.calendar.dateComponents([.year, .month, .day], from: date)
    }
    
    static func toDate(_ dateComponents: DateComponents) -> Date? {
        return DateManager.calendar.date(from: dateComponents)
    }
    
    static func toString(date: Date,
                         format: DateStringFormat) -> String? {
        switch format {
        case .full:
            return DateManager.detailDateFormatter.string(from: date)
        case .simple:
            return DateManager.simpleDateFormatter.string(from: date)
        }
    }
}

// MARK: - 추출
extension Date {
    func getHours() -> Int {
        return DateManager.calendar.dateComponents([.hour], from: self).hour ?? 0
    }
}



