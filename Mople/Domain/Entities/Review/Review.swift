//
//  Review.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

struct Review {
    var creatorId: Int?
    var id: Int?
    var name: String?
    var date: Date?
    var participantsCount: Int?
    var address: String?
    var addressTitle: String?
    var images: [String]
    var meet: MeetSummary?
    var location: Location?
    var isCreator: Bool = false
    var isReviewd: Bool = false
}

extension Review {
    mutating func verifyCreator(_ userId: Int?) {
        guard let creatorId,
              let userId else { return }
        isCreator = creatorId == userId
    }
}
