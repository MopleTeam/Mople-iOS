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
        self.title = "백설공주 없는 일곱 난쟁이"
        self.place = "제주도 여행"
        self.detailPlace = "제주 제주시 애월읍 납읍로 21\n애월후식제주"
        self.releaseDate = schedule.stringDate
        self.participants = schedule.participants
    }
}
