//
//  CalendarData.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

enum MonthlyPlanType {
    case plan
    case review
}

struct MonthlyPlan {
    let id: Int?
    let title: String?
    let date: Date?
    let memberCount: Int?
    var meet: MeetSummary?
    let weather: Weather?
    let type: MonthlyPlanType
}
