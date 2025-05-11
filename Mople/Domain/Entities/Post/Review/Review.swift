//
//  Review.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import UIKit

struct Review: Comparable {
    var id: Int?
    var creatorId: Int?
    var postId: Int?
    var name: String?
    var date: Date?
    var participantsCount: Int = 0
    var address: String?
    var addressTitle: String?
    var images: [ReviewImage]
    var meet: MeetSummary?
    var location: Location?
    var isCreator: Bool = false
    var isReviewd: Bool
    
    static func < (lhs: Review, rhs: Review) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

extension Review {
    mutating func verifyCreator(_ userId: Int?) {
        guard let creatorId,
              let userId else { return }
        isCreator = creatorId == userId
    }
}
