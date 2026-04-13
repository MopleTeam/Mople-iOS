//
//  Review.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

public struct Review: Comparable {
    public var id: Int?
    public var creatorId: Int?
    public var postId: Int?
    public var name: String?
    public var date: Date?
    public var participantsCount: Int = 0
    public var address: String?
    public var addressTitle: String?
    public var images: [ReviewImage]
    public var meet: MeetSummary?
    public var location: Location?
    public var isCreator: Bool = false
    public var isReviewd: Bool
    public var commentCount: Int = 0
    public let description: String?

    public init(id: Int? = nil, creatorId: Int? = nil, postId: Int? = nil, name: String? = nil, date: Date? = nil, participantsCount: Int = 0, address: String? = nil, addressTitle: String? = nil, images: [ReviewImage], meet: MeetSummary? = nil, location: Location? = nil, isCreator: Bool = false, isReviewd: Bool, commentCount: Int = 0, description: String? = nil) {
        self.id = id
        self.creatorId = creatorId
        self.postId = postId
        self.name = name
        self.date = date
        self.participantsCount = participantsCount
        self.address = address
        self.addressTitle = addressTitle
        self.images = images
        self.meet = meet
        self.location = location
        self.isCreator = isCreator
        self.isReviewd = isReviewd
        self.commentCount = commentCount
        self.description = description
    }

    public static func < (lhs: Review, rhs: Review) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

public extension Review {
    public mutating func verifyCreator(_ userId: Int?) {
        guard let creatorId,
              let userId else { return }
        isCreator = creatorId == userId
    }
}
