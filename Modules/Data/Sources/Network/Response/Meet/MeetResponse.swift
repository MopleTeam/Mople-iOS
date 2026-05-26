//
//  MeetResponse.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import Domain

struct MeetResponse: Decodable {
    let meetId: Int?
    let version: Int?
    let meetName: String?
    let meetImage: String?
    let sinceDays: Int?
    let hostId: Int?
    let memberCount: Int?
    let lastPlanDay: String?
    let pinnedNotice: PinnedNoticeResponse?
}

extension MeetResponse {
    func toDomain() -> Meet {
        let date = DateManager.parseServerFullDate(string: lastPlanDay)

        return .init(meetSummary: .init(id: meetId,
                                        name: meetName,
                                        imagePath: meetImage),
                     sinceDays: sinceDays,
                     creatorId: hostId,
                     memberCount: memberCount,
                     firstPlanDate: date,
                     version: version,
                     pinnedNotice: pinnedNotice?.toDomain())
    }
}
