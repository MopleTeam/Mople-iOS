//
//  Plan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

struct Plan: Hashable, Equatable {
    let id: Int?
    let creatorId: Int?
    let title: String?
    let date: Date?
    var participationCount: Int = 0
    var isParticipation: Bool = false
    let addressTitle: String?
    let address: String?
    var meet: MeetSummary?
    let location: Location?
    let weather: Weather?
    var isCreator: Bool = false
    
    var startOfDate: Date? {
        guard let date = date else { return nil }
        return DateManager.startOfDay(date)
    }
    
    static func < (lhs: Plan, rhs: Plan) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

extension Plan {
    mutating func verifyCreator(_ userId: Int?) {
        guard let creatorId,
              let userId else { return }
        isCreator = creatorId == userId
    }
    
    mutating func updateParticipants() -> Self {
        if isParticipation {
            isParticipation = false
            participationCount -= 1
        } else {
            isParticipation = true
            participationCount += 1
        }
        return self
    }
}




