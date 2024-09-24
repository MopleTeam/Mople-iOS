//
//  AppCalendar.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation

final class DateManager {
    
    static let calendar = Calendar.current
    
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
