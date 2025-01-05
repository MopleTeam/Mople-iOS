//
//  MeetResponse.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation

struct MeetResponse: Decodable {
    var meetSummary: MeetSummaryResponse
    var sinceDays: Int?
    var creatorId: Int?
    var memberCount: Int?
    var lastPlanDay: String?
}

extension MeetResponse {
    func toDomain() -> Meet {
        let date = DateManager.parseServerDate(string: lastPlanDay)
        
        return .init(meetSummary: meetSummary.toDomain(),
                     sinceDays: sinceDays,
                     creatorId: creatorId,
                     memberCount: memberCount,
                     firstPlanDate: date)
    }
}
