//
//  CalendarPlanViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

struct ScheduleListViewModel {
    let title: String?
    let meet: MeetSummary?
    let participantCount: Int
    let weather: Weather?
    
    var participantCountString: String {        
        return "\(participantCount)명 참여"
    }
}

extension ScheduleListViewModel {
    init(plan: MonthlyPlan) {
        self.title = plan.title
        self.meet = plan.meet
        self.participantCount = plan.memberCount
        self.weather = plan.weather
    }
}
