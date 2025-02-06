//
//  MeetResponse.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation

struct MeetResponse: Decodable {
    let meetId: Int?
    let meetName: String?
    let meetImage: String?
    let sinceDays: Int?
    let creatorId: Int?
    let memberCount: Int?
    let lastPlanDay: String?
}

extension MeetResponse {
    func toDomain() -> Meet {
        let date = DateManager.parseServerDate(string: lastPlanDay)
        
        return .init(meetSummary: .init(id: meetId,
                                        name: meetName,
                                        imagePath: meetImage),
                     sinceDays: sinceDays,
                     creatorId: creatorId,
                     memberCount: memberCount,
                     firstPlanDate: date)
    }
}
