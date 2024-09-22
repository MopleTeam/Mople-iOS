//
//  ScheduleListItemViewModel.swift
//  Group
//
//  Created by CatSlave on 9/5/24.
//

import Foundation

struct ScheduleListItemViewModel {
    let group: Group
    let title: String
    let date: String
    let place: String
    let participantCount: Int
}

extension ScheduleListItemViewModel {
    init(schedule: Schedule) {
        self.group = schedule.group
        self.title = schedule.title
        self.place = schedule.place
        self.date = schedule.stringDate
        self.participantCount = schedule.participants.count
    }
}
