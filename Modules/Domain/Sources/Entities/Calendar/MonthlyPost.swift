//
//  CalendarData.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

public enum MonthlyPostType {
    case plan
    case review
}

public struct MonthlyPost: Equatable  {
    public let id: Int?
    public var title: String?
    public var date: Date?
    public var memberCount: Int
    public var meet: MeetSummary?
    public var weather: Weather?
    public let type: MonthlyPostType
    public var isCreator: Bool = false

    public init(id: Int? = nil, title: String? = nil, date: Date? = nil, memberCount: Int, meet: MeetSummary? = nil, weather: Weather? = nil, type: MonthlyPostType, isCreator: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.memberCount = memberCount
        self.meet = meet
        self.weather = weather
        self.type = type
        self.isCreator = isCreator
    }
}

public extension MonthlyPost {
    public init(plan: Plan) {
        self.id = plan.id
        self.title = plan.title
        self.date = plan.date
        self.memberCount = plan.participationCount
        self.meet = plan.meet
        self.weather = plan.weather
        self.type = .plan
    }
    
    public mutating func verifyCreator(_ userId: Int?) {
//        guard let creatorId,
//              let userId else { return }
//        isCreator = creatorId == userId
    }
}
