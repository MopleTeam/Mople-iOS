//
//  MeetResponse.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation

struct MeetResponse: Decodable {
    var meetId: Int?
    var meetName: String?
    var meetImage: String?
    var sinceDays: Int?
    var creatorId: Int?
    var memberCount: Int?
    var lastPlanDay: String?
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
