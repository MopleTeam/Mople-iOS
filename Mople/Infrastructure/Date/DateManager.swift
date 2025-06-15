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
    case month
}

final class DateManager {
    
    static var todayComponents: DateComponents {
        return Date().toDateComponents()
    }
    
    static let calendar = Calendar.current
    
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = L10n.Date.Format.full
        return formatter
    }()
    
    static let basicDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = L10n.Date.Format.basic
        return formatter
    }()
    
    static let dotDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = L10n.Date.Format.dot
        return formatter
    }()
    
    static let timeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = L10n.Date.Format.time
        return formatter
    }()
    
    static let monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = L10n.Date.Format.month
        return formatter
    }()
    
    static let fullServerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = L10n.Date.Format.serverFull
        return formatter
    }()
    
    static let simpleServerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = L10n.Date.Format.serverSimple
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
    
    static func isFutureOrToday(on date: Date) -> Bool {
        return isToday(on: date) || Date() < date
    }
    
    static func isPastDay(on date: Date) -> Bool {
        return date < Date() && isToday(on: date) == false
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
    
    static func isWithinRange(target: Date, from: Date, to: Date) -> Bool {
        return from <= target && to >= target
    }
}

// MARK: - 추출
extension DateManager {
    
    static func numberOfTimeBetween(_ date: Date) -> DateComponents {
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: date)
    }
    
    static func numberOfDaysBetween(_ date: Date) -> Int {
        let scheduleDate = startOfDay(date)
        let today = startOfDay(Date())
        let result = calendar.dateComponents([.day], from: today, to: scheduleDate)
        return result.day ?? 0
    }
    
    static func numberOfMonthBetween(_ date: Date) -> Int {
        let todayYear = calendar.component(.year, from: Date())
        let todayMonth = calendar.component(.month, from: Date())
        
        let targetYear = calendar.component(.year, from: date)
        let targetMonth = calendar.component(.month, from: date)
        
        return (targetMonth - todayMonth) + (targetYear - todayYear) * 12
    }
    
    static func weekBasedYear(_ date: Date) -> Int {
        return DateManager.calendar.component(.yearForWeekOfYear, from: date)
    }
}

// MARK: - 전환
extension DateManager {
    static func startOfDay(_ date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    static func startOfMonth(_ date: Date) -> Date? {
        return date.toMonthComponents().toDate()
    }

    static func getNextMonth(_ date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date) ?? Date()
    }
    
    static func getPreviousMonth(_ date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date) ?? Date()
    }
    
    static func addFiveMinutes(_ date: Date) -> Date {
        return calendar.date(byAdding: .minute, value: +5, to: date) ?? Date()
    }
    
    static func subtractFiveMinutes(_ date: Date) -> Date {
        return calendar.date(byAdding: .minute, value: -5, to: date) ?? Date()
    }
    
    static func parseServerFullDate(string: String?) -> Date? {
        guard let string else { return nil }
        return DateManager.fullServerDateFormatter.date(from: string)
    }
    
    static func parseServerSimpleDate(string: String?) -> Date? {
        guard let string else { return nil }
        return DateManager.basicDateFormatter.date(from: string)
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
    
    static func combineDayAndTime(day: DateComponents, time: DateComponents) -> Date? {
        return DateComponents(year: day.year,
                              month: day.month,
                              day: day.day,
                              hour: time.hour,
                              minute: time.minute).toDate()
    }
}

// MARK: - 문자열 전환
extension DateManager {
    static func toServerDateString(_ date: Date) -> String {
        return DateManager.fullServerDateFormatter.string(from: date)
    }
    
    static func toString(date: Date?,
                         format: DateStringFormat) -> String? {
        guard let date else { return nil }
        switch format {
        case .full:
            return DateManager.fullDateFormatter.string(from: date)
        case .simple:
            return DateManager.basicDateFormatter.string(from: date)
        case .time:
            return addPeriodPrefix(on: date)
        case .dot:
            return DateManager.dotDateFormat.string(from: date)
        case .month:
            return DateManager.monthDateFormatter.string(from: date)
        }
    }
    
    static func addPeriodPrefix(on date: Date) -> String? {
        guard let hour = date.getTime().hour else { return nil }
        
        if hour >= 12 {
            let convertDate = DateManager.convertTo12Hour(date.getTime())
            guard let date = convertDate.toDate() else { return nil }
            return [L10n.Date.Period.pm, Self.timeDateFormatter.string(from: date)].joined(separator: " ")
        } else {
            return [L10n.Date.Period.am, Self.timeDateFormatter.string(from: date)].joined(separator: " ")
        }
    }
}

// MARK: - 변환
extension Date {
    func toDateComponents() -> DateComponents {
        return DateManager.calendar.dateComponents([.year, .month, .day], from: self)
    }
    
    func toMonthComponents() -> DateComponents {
        return DateManager.calendar.dateComponents([.year, .month], from: self)
    }
    
    func getTime() -> DateComponents {
        return DateManager.calendar.dateComponents([.hour, .minute], from: self)
    }
    
    func timeAgoDescription() -> String? {
        let betweenCount = DateManager.numberOfTimeBetween(self)
        
        let components = [
            (betweenCount.year, L10n.Date.Label.year),
            (betweenCount.month, L10n.Date.Label.month),
            (betweenCount.day, L10n.Date.Label.day),
            (betweenCount.hour, L10n.Date.Label.hour),
            (betweenCount.minute, L10n.Date.Label.minute),
            (betweenCount.second, L10n.Date.Label.second)
        ]
        
        guard let (value, unit) = components.first(where: { $0.0 != 0 }),
              let value else { return L10n.Date.Duration.agoDefaul }
        
        return "\(abs(value))\(unit)" + " " + L10n.Date.Duration.ago
    }
}

extension DateComponents {
    func toDate() -> Date? {
        return DateManager.calendar.date(from: self)
    }
}
