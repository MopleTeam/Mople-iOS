//
//  Plan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

struct Plan: Hashable, Equatable {
    let id: Int?
    let title: String?
    let date: Date?
    let participantCount: Int?
    let isParticipating: Bool?
    let addressTitle: String?
    let address: String?
    let meetngSummary: MeetSummary?
    let location: Location?
    let weather: Weather?
    
    static func < (lhs: Plan, rhs: Plan) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

extension Plan {
    var startOfDate: Date? {
        guard let date = date else { return nil }
        return DateManager.startOfDay(date)
    }
}




