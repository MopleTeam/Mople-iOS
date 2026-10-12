//
//  Plan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

public struct Plan: Hashable, Comparable {
    public let id: Int?
    public let creatorId: Int?
    public let title: String?
    public let date: Date?
    public var participationCount: Int = 0
    public var isParticipation: Bool = false
    public let addressTitle: String?
    public let address: String?
    public var meet: MeetSummary?
    public let location: Location?
    public let weather: Weather?
    public var isCreator: Bool = false
    public var commentCount: Int = 0
    public var description: String?

    public init(id: Int? = nil, creatorId: Int? = nil, title: String? = nil, date: Date? = nil, participationCount: Int = 0, isParticipation: Bool = false, addressTitle: String? = nil, address: String? = nil, meet: MeetSummary? = nil, location: Location? = nil, weather: Weather? = nil, isCreator: Bool = false, commentCount: Int = 0, description: String? = nil) {
        self.id = id
        self.creatorId = creatorId
        self.title = title
        self.date = date
        self.participationCount = participationCount
        self.isParticipation = isParticipation
        self.addressTitle = addressTitle
        self.address = address
        self.meet = meet
        self.location = location
        self.weather = weather
        self.isCreator = isCreator
        self.commentCount = commentCount
        self.description = description
    }

    public var startOfDate: Date? {
        guard let date = date else { return nil }
        return Calendar.current.startOfDay(for: date)
    }
    
    public static func < (lhs: Plan, rhs: Plan) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

public extension Plan {
    public mutating func verifyCreator(_ userId: Int?) {
        guard let creatorId,
              let userId else { return }
        isCreator = creatorId == userId
    }
    
    @discardableResult
    public mutating func updateParticipants() -> Self {
        participationCount += isParticipation ? -1 : 1
        isParticipation.toggle()
        return self
    }
}




