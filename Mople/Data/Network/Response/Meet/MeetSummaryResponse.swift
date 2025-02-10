//
//  MeetSummaryResponse.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

struct MeetSummaryResponse: Decodable {
    let meetId: Int?
    let meetName: String?
    let meetImage: String?
}

extension MeetSummaryResponse {
    func toDomain() -> MeetSummary {
        return .init(id: meetId,
                     name: meetName,
                     imagePath: meetImage)
    }
}
