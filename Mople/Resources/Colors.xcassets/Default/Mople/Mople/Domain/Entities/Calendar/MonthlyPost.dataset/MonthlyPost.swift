//
//  CalendarData.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

enum MonthlyPostType {
    case plan
    case review
}

struct MonthlyPost: Equatable  {
    let id: Int?
    var title: String?
    var date: Date?
    var memberCount: Int
    var meet: MeetSummary?
    var weather: Weather?
    let type: MonthlyPostType
}

extension MonthlyPost {
    init(plan: Plan) {
        self.id = plan.id
        self.title = plan.title
        self.date = plan.date
        self.memberCount = plan.participationCount
        self.meet = plan.meet
        self.weather = plan.weather
        self.type = .plan
    }
}
