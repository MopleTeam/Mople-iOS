//
//  ScheduleListItemViewModel.swift
//  Group
//
//  Created by CatSlave on 9/5/24.
//

import Foundation

struct ScheduleListItemViewModel {
    let remainingDayCount: Int
    let title: String
    let place: String
    let releaseDate: String
    let detailPlace: String
    let participants: [Participant]
}

extension ScheduleListItemViewModel {
    init(schedule: Schedule) {
        self.remainingDayCount = 3
        self.title = "스케쥴 제목"
        self.place = "지역명"
        self.detailPlace = "자세한 지역명"
        self.releaseDate = "자세한 날짜"
        self.participants = schedule.participants ?? []
    }
}
