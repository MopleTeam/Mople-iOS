//
//  AppCalendar.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation

enum DateStringFormat {
    case full
    case dot
    case simple
    case time
}

final class DateManager {
    
    static var todayComponents: DateComponents {
        return Date().toDateComponents()
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
    
    static let dotDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy. MM. dd E"
        return formatter
    }()

    
    static let timeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH시 mm분"
        return formatter
    }()
    
    static let serverDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
        let firstDate = components.toDate() ?? Date()
        return calendar.date(byAdding: .year, value: -10, to: firstDate) ?? Date()
    }

    /// 앱에서 표시할 최대 날짜
    static func getMaximumDate() -> Date {
        var components = self.todayComponents
        components.month = 12
        components.day = 31
        let lastDate = components.toDate() ?? Date()
        return calendar.date(byAdding: .year, value: 10, to: lastDate) ?? Date()
    }
    
    /// 현재 달의 최대 일수
    static func getDaysCountInCurrentMonth(on dateComponents: DateComponents) -> Int {
        var calculateDate = dateComponents
        calculateDate.day = 1
        
        guard let date = calculateDate.toDate(),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 28
        }
        return range.count
    }
}

// MARK: - 비교
extension DateManager {
    static func isToday(on date: Date) -> Bool {
        return calendar.isDateInToday(date)
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

// MARK: - 추출
extension DateManager {
    
    static func numberOfTimeBetween(_ date: Date) -> DateComponents {
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: date)
    }
    
    static func numberOfDaysBetween(_ date: Date) -> Int {
        let scheduleDate = startOfDay(date)
        let result = calendar.dateComponents([.day], from: Date(), to: scheduleDate)
        return result.day ?? 0
    }
    
    static func numberOfMonthBetween(_ date: Date) -> Int {
        let todayYear = calendar.component(.year, from: Date())
        let todayMonth = calendar.component(.month, from: Date())
        
        let targetYear = calendar.component(.year, from: date)
        let targetMonth = calendar.component(.month, from: date)
        
        return (targetMonth - todayMonth) + (targetYear - todayYear) * 12
    }
}

// MARK: - 전환
extension DateManager {
    static func startOfDay(_ date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }

    static func isNextMonth(_ date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date) ?? Date()
    }
    
    static func isPreviousMonth(_ date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date) ?? Date()
    }
    
    static func addFiveMinutes(_ date: Date) -> Date {
        return calendar.date(byAdding: .minute, value: +5, to: date) ?? Date()
    }
    
    static func subtractFiveMinutes(_ date: Date) -> Date {
        return calendar.date(byAdding: .minute, value: -5, to: date) ?? Date()
    }
    
    static func parseServerDate(string: String?) -> Date? {
        guard let string else { return nil }
        return DateManager.serverDateFormatter.date(from: string)
    }
    
    static func convertTo24Hour(_ date: DateComponents) -> DateComponents {
        var convertDate = date
        guard let hour = convertDate.hour,
              hour < 12 else { return date }
        convertDate.hour = hour + 12
        return convertDate
    }
    
    static func convertTo12Hour(_ date: DateComponents) -> DateComponents {
        var convertDate = date
        guard let hour = convertDate.hour,
              hour > 12 else { return date }
        convertDate.hour = hour % 12
        return convertDate
    }
}

// MARK: - 문자열 전환
extension DateManager {
    static func toServerDateString(_ date: Date) -> String {
        return DateManager.serverDateFormatter.string(from: date)
    }
    
    static func toString(date: Date?,
                         format: DateStringFormat) -> String? {
        guard let date else { return nil }
        switch format {
        case .full:
            return DateManager.detailDateFormatter.string(from: date)
        case .simple:
            return DateManager.simpleDateFormatter.string(from: date)
        case .time:
            return addPeriodPrefix(on: date)
        case .dot:
            return DateManager.dotDateFormat.string(from: date)
        }
    }
    
    static func addPeriodPrefix(on date: Date) -> String? {
        guard let hour = date.getTime().hour else { return nil }
        
        if hour >= 12 {
            let convertDate = DateManager.convertTo12Hour(date.getTime())
            guard let date = convertDate.toDate() else { return nil }
            return ["오후", Self.timeDateFormatter.string(from: date)].joined(separator: " ")
        } else {
            return ["오전", Self.timeDateFormatter.string(from: date)].joined(separator: " ")
        }
    }
}

// MARK: - 변환
extension Date {
    func toDateComponents() -> DateComponents {
        return DateManager.calendar.dateComponents([.year, .month, .day], from: self)
    }
    
    func getTime() -> DateComponents {
        return DateManager.calendar.dateComponents([.hour, .minute], from: self)
    }
}

extension DateComponents {
    func toDate() -> Date? {
        return DateManager.calendar.date(from: self)
    }
}



