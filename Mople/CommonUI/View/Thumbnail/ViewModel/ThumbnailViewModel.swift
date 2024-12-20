//
//  ThumbnailViewModel.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import Foundation

struct ThumbnailViewModel {
    let name: String?
    let thumbnailPath: String?
    let memberCount: Int?
    let lastPlanDate: Date?
}

extension ThumbnailViewModel {
    init(meet: MeetSummary?,
         memberCount: Int? = nil,
         lastPlanDate: Date? = nil) {
        self.name = "\(meet?.id)"
        self.thumbnailPath = meet?.imagePath
        self.memberCount = memberCount
        self.lastPlanDate = lastPlanDate
    }
}
