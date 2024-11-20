//
//  Schedulable.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

protocol Schedulable {
    var commonScheudle: CommonSchedule? { get }
}

extension Schedulable {
    var id: Int? { commonScheudle?.id }
    var title: String? { commonScheudle?.title }
    var date: Date? { commonScheudle?.date }
    var address: String? { commonScheudle?.address }
    var detailAddress: String? { commonScheudle?.detailAddress }
    var startOfDate: Date? { commonScheudle?.startOfDate }
}

struct CommonSchedule: Hashable, Equatable {
    let id: Int?
    let title: String?
    let date: Date?
    let address: String?
    let detailAddress: String?
    
    static func < (lhs: CommonSchedule, rhs: CommonSchedule) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

extension CommonSchedule {
    var startOfDate: Date? {
        guard let date = date else { return nil }
        return DateManager.startOfDay(date)
    }
}
