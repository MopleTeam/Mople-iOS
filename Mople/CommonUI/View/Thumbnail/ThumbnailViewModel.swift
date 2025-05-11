//
//  ThumbnailViewModel.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import Foundation

struct ThumbnailViewModel {
    var name: String?
    var thumbnailPath: String?
    var memberCount: Int?
    var lastPlanDate: Date?
    
    var memberCountString: String? {
        guard let memberCount else { return nil }
        return L10n.peopleCount(memberCount)
    }
}

extension ThumbnailViewModel {
    init(meetSummary: MeetSummary?) {
        self.name = meetSummary?.name
        self.thumbnailPath = meetSummary?.imagePath
    }
    
    init(meet: Meet) {
        self.init(meetSummary: meet.meetSummary)
        self.memberCount = meet.memberCount
        self.lastPlanDate = meet.firstPlanDate
    }
}
